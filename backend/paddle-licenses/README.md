# FlowDesk — API de licenças (Paddle)

Worker Cloudflare que conecta o Paddle Billing ao licenciamento premium do
FlowDesk. Recebe webhooks de assinatura, gera license keys e emite
entitlements assinados (Ed25519) que o app verifica offline.

## Fluxo

1. Usuário clica em **Assinar** no app → abre o checkout hospedado do Paddle
   no navegador.
2. Paddle processa o pagamento e dispara `transaction.completed` +
   `subscription.activated` para `/webhooks/paddle`; o worker gera a license
   key.
3. A página de sucesso do checkout (configurada no Paddle) chama
   `GET /v1/licenses/claim?transaction_id=...` e exibe a key para o usuário
   (com retry, pois o webhook pode chegar segundos depois).
4. Usuário cola a key no app → `POST /v1/licenses/activate` registra o
   dispositivo (máx. 3) e devolve o entitlement assinado.
5. O app revalida periodicamente via `POST /v1/licenses/validate`;
   cancelamento/inadimplência chegam por webhook e o worker passa a negar.

## Setup

### 1. Chaves de assinatura

```bash
node scripts/generate-keys.mjs
```

- Chave privada → `wrangler secret put ED25519_PRIVATE_KEY`
- Chave pública → `licensePublicKeyBase64` em
  `lib/core/constants/app_constants.dart`

### 2. Cloudflare

```bash
npm install -g wrangler
wrangler kv namespace create LICENSES   # cole o id no wrangler.toml
wrangler secret put ED25519_PRIVATE_KEY
wrangler secret put PADDLE_WEBHOOK_SECRET
wrangler deploy
```

### 3. Paddle (dashboard)

1. Crie o produto **FlowDesk Premium** com um preço recorrente mensal (e
   anual, se quiser).
2. Crie um **checkout link** hospedado e cole a URL em
   `AppConstants.checkoutUrl`.
3. Em *Developer Tools → Notifications*, crie um destino webhook apontando
   para `https://<seu-worker>/webhooks/paddle` com os eventos:
   `transaction.completed`, `subscription.activated`,
   `subscription.trialing`, `subscription.resumed`, `subscription.updated`,
   `subscription.past_due`, `subscription.canceled`.
   Copie o secret para o secret `PADDLE_WEBHOOK_SECRET`.
4. Configure a página de sucesso do checkout para exibir a license key
   (chamando `/v1/licenses/claim` com o `transaction_id` do redirect).
5. Atualize `AppConstants.licenseApiBaseUrl` com a URL do worker.

Use o [sandbox do Paddle](https://sandbox-vendors.paddle.com) com cartões de
teste antes de ir para produção.

## Endpoints

| Método | Rota | Descrição |
|---|---|---|
| POST | `/webhooks/paddle` | Webhooks do Paddle (assinatura verificada) |
| GET | `/v1/licenses/claim?transaction_id=` | Resgata a key após o checkout |
| POST | `/v1/licenses/activate` | `{key, deviceId, deviceName, platform}` → entitlement |
| POST | `/v1/licenses/validate` | `{key, deviceId}` → entitlement renovado |
| POST | `/v1/licenses/deactivate` | `{key, deviceId}` → libera o seat |

O entitlement é `{payload, signature}` — payload base64 de um JSON
`{key, plan, deviceId, premiumUntil, issuedAt}` assinado com Ed25519.
