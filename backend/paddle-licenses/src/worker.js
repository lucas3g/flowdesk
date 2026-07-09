/**
 * FlowDesk — API de licenças (Cloudflare Worker).
 *
 * Recebe webhooks do Paddle Billing, gera license keys por assinatura e
 * emite entitlements assinados (Ed25519) que o app desktop verifica
 * offline com a chave pública embutida.
 *
 * Armazenamento (KV namespace LICENSES):
 *   license:<key>  → { key, subscriptionId, email, status, premiumUntil, devices[] }
 *   sub:<subId>    → license key
 *   txn:<txnId>    → subscription id (para a página de sucesso resgatar a key)
 *
 * Secrets (wrangler secret put):
 *   PADDLE_WEBHOOK_SECRET   — secret do destino de notificações no Paddle
 *   ED25519_PRIVATE_KEY     — chave privada PKCS8 em base64 (generate-keys.mjs)
 */

const MAX_DEVICES = 3;

/** Folga além da próxima cobrança para absorver retries de pagamento. */
const BILLING_SLACK_DAYS = 3;

export default {
  async fetch(request, env) {
    const url = new URL(request.url);
    try {
      if (request.method === 'POST' && url.pathname === '/webhooks/paddle') {
        return await handlePaddleWebhook(request, env);
      }
      if (request.method === 'GET' && url.pathname === '/v1/licenses/claim') {
        return await handleClaim(url, env);
      }
      if (request.method === 'POST' && url.pathname === '/v1/licenses/activate') {
        return await handleActivate(request, env);
      }
      if (request.method === 'POST' && url.pathname === '/v1/licenses/validate') {
        return await handleValidate(request, env);
      }
      if (request.method === 'POST' && url.pathname === '/v1/licenses/deactivate') {
        return await handleDeactivate(request, env);
      }
      return json({ error: 'Rota não encontrada' }, 404);
    } catch (e) {
      console.error(e);
      return json({ error: 'Erro interno' }, 500);
    }
  },
};

// ---------------------------------------------------------------- Webhook

async function handlePaddleWebhook(request, env) {
  const rawBody = await request.text();
  const signatureHeader = request.headers.get('Paddle-Signature') || '';

  const valid = await verifyPaddleSignature(
    rawBody,
    signatureHeader,
    env.PADDLE_WEBHOOK_SECRET,
  );
  if (!valid) return json({ error: 'Assinatura inválida' }, 401);

  const event = JSON.parse(rawBody);
  const data = event.data ?? {};

  switch (event.event_type) {
    // Mapeia a transação do checkout para a assinatura, permitindo que a
    // página de sucesso resgate a license key via /v1/licenses/claim.
    case 'transaction.completed':
      if (data.subscription_id) {
        await env.LICENSES.put(`txn:${data.id}`, data.subscription_id, {
          expirationTtl: 60 * 60 * 24 * 30,
        });
      }
      break;

    case 'subscription.activated':
    case 'subscription.trialing':
    case 'subscription.resumed':
    case 'subscription.updated':
      await upsertLicense(env, data, 'active');
      break;

    case 'subscription.past_due':
      await upsertLicense(env, data, 'past_due');
      break;

    case 'subscription.canceled':
      await upsertLicense(env, data, 'canceled');
      break;
  }

  return json({ ok: true });
}

/**
 * Valida o header `Paddle-Signature` (formato `ts=...;h1=...`):
 * HMAC-SHA256 de `${ts}:${rawBody}` com o secret do webhook.
 */
async function verifyPaddleSignature(rawBody, header, secret) {
  const parts = Object.fromEntries(
    header.split(';').map((p) => p.split('=', 2)),
  );
  const ts = parts.ts;
  const h1 = parts.h1;
  if (!ts || !h1 || !secret) return false;

  // Rejeita eventos com mais de 15 minutos (replay).
  if (Math.abs(Date.now() / 1000 - Number(ts)) > 900) return false;

  const key = await crypto.subtle.importKey(
    'raw',
    new TextEncoder().encode(secret),
    { name: 'HMAC', hash: 'SHA-256' },
    false,
    ['sign'],
  );
  const mac = await crypto.subtle.sign(
    'HMAC',
    key,
    new TextEncoder().encode(`${ts}:${rawBody}`),
  );
  const expected = [...new Uint8Array(mac)]
    .map((b) => b.toString(16).padStart(2, '0'))
    .join('');
  return timingSafeEqual(expected, h1);
}

function timingSafeEqual(a, b) {
  if (a.length !== b.length) return false;
  let diff = 0;
  for (let i = 0; i < a.length; i++) diff |= a.charCodeAt(i) ^ b.charCodeAt(i);
  return diff === 0;
}

/** Cria/atualiza a licença da assinatura a partir do payload do webhook. */
async function upsertLicense(env, subscription, status) {
  const subId = subscription.id;
  if (!subId) return;

  let key = await env.LICENSES.get(`sub:${subId}`);
  let license = key
    ? JSON.parse((await env.LICENSES.get(`license:${key}`)) ?? 'null')
    : null;

  if (!license) {
    key = generateLicenseKey();
    license = { key, subscriptionId: subId, devices: [] };
    await env.LICENSES.put(`sub:${subId}`, key);
  }

  license.status = status;
  license.premiumUntil = premiumUntilFrom(subscription, license.premiumUntil);

  await env.LICENSES.put(`license:${key}`, JSON.stringify(license));
}

/** Fim do período pago: fim do ciclo atual + folga para retries. */
function premiumUntilFrom(subscription, fallback) {
  const endsAt =
    subscription.current_billing_period?.ends_at ??
    subscription.items?.[0]?.next_billed_at ??
    fallback;
  if (!endsAt) return fallback ?? null;

  const date = new Date(endsAt);
  date.setUTCDate(date.getUTCDate() + BILLING_SLACK_DAYS);
  return date.toISOString();
}

function generateLicenseKey() {
  const alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  const bytes = crypto.getRandomValues(new Uint8Array(16));
  const chars = [...bytes].map((b) => alphabet[b % alphabet.length]);
  return `FD-${chars.slice(0, 4).join('')}-${chars.slice(4, 8).join('')}-${chars
    .slice(8, 12)
    .join('')}-${chars.slice(12).join('')}`;
}

// ------------------------------------------------------- Endpoints do app

/** Página de sucesso do checkout resgata a key pela transação. */
async function handleClaim(url, env) {
  const txnId = url.searchParams.get('transaction_id');
  if (!txnId) return json({ error: 'transaction_id obrigatório' }, 400);

  const subId = await env.LICENSES.get(`txn:${txnId}`);
  const key = subId && (await env.LICENSES.get(`sub:${subId}`));
  if (!key) {
    // O webhook pode ainda não ter chegado — a página deve tentar de novo.
    return json({ error: 'Licença ainda não disponível' }, 404);
  }
  return json({ key });
}

async function handleActivate(request, env) {
  const body = await request.json();
  const { key, deviceId, deviceName, platform } = body;
  if (!key || !deviceId) {
    return json({ error: 'key e deviceId são obrigatórios' }, 400);
  }

  const license = JSON.parse(
    (await env.LICENSES.get(`license:${key}`)) ?? 'null',
  );
  if (!license) return json({ error: 'Chave de licença não encontrada' }, 404);
  if (isRevoked(license)) {
    return json({ error: 'Assinatura cancelada ou expirada' }, 410);
  }

  if (!license.devices.some((d) => d.id === deviceId)) {
    if (license.devices.length >= MAX_DEVICES) {
      return json(
        { error: `Limite de ${MAX_DEVICES} dispositivos atingido` },
        409,
      );
    }
    license.devices.push({
      id: deviceId,
      name: deviceName ?? '',
      platform: platform ?? '',
      activatedAt: new Date().toISOString(),
    });
    await env.LICENSES.put(`license:${key}`, JSON.stringify(license));
  }

  return json(await signEntitlement(env, license, deviceId));
}

async function handleValidate(request, env) {
  const { key, deviceId } = await request.json();
  if (!key || !deviceId) {
    return json({ error: 'key e deviceId são obrigatórios' }, 400);
  }

  const license = JSON.parse(
    (await env.LICENSES.get(`license:${key}`)) ?? 'null',
  );
  if (!license) return json({ error: 'Chave de licença não encontrada' }, 404);
  if (!license.devices.some((d) => d.id === deviceId)) {
    return json({ error: 'Dispositivo não ativado para esta licença' }, 403);
  }
  if (isRevoked(license)) {
    return json({ error: 'Assinatura cancelada ou expirada' }, 410);
  }

  return json(await signEntitlement(env, license, deviceId));
}

async function handleDeactivate(request, env) {
  const { key, deviceId } = await request.json();
  if (!key || !deviceId) {
    return json({ error: 'key e deviceId são obrigatórios' }, 400);
  }

  const license = JSON.parse(
    (await env.LICENSES.get(`license:${key}`)) ?? 'null',
  );
  if (license) {
    license.devices = license.devices.filter((d) => d.id !== deviceId);
    await env.LICENSES.put(`license:${key}`, JSON.stringify(license));
  }
  return json({ ok: true });
}

/**
 * Cancelada só é revogada após o fim do período já pago; past_due
 * mantém acesso (a tolerância curta fica no cliente).
 */
function isRevoked(license) {
  if (license.status === 'canceled') {
    return !license.premiumUntil || new Date(license.premiumUntil) < new Date();
  }
  return false;
}

// ----------------------------------------------------------- Entitlement

async function signEntitlement(env, license, deviceId) {
  const payload = JSON.stringify({
    key: license.key,
    plan: 'premium',
    deviceId,
    premiumUntil: license.premiumUntil,
    issuedAt: new Date().toISOString(),
  });
  const payloadBytes = new TextEncoder().encode(payload);

  const privateKey = await crypto.subtle.importKey(
    'pkcs8',
    base64ToBytes(env.ED25519_PRIVATE_KEY),
    { name: 'Ed25519' },
    false,
    ['sign'],
  );
  const signature = await crypto.subtle.sign('Ed25519', privateKey, payloadBytes);

  return {
    payload: bytesToBase64(payloadBytes),
    signature: bytesToBase64(new Uint8Array(signature)),
  };
}

// ------------------------------------------------------------- Utilitários

function json(body, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { 'Content-Type': 'application/json' },
  });
}

function base64ToBytes(b64) {
  return Uint8Array.from(atob(b64), (c) => c.charCodeAt(0));
}

function bytesToBase64(bytes) {
  let binary = '';
  for (const b of bytes) binary += String.fromCharCode(b);
  return btoa(binary);
}
