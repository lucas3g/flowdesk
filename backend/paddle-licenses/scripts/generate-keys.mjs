/**
 * Gera o par de chaves Ed25519 do licenciamento.
 *
 *   node scripts/generate-keys.mjs
 *
 * - A chave PRIVADA (base64 PKCS8) vai para o worker:
 *     wrangler secret put ED25519_PRIVATE_KEY
 * - A chave PÚBLICA (base64, 32 bytes) vai para o app, em
 *     lib/core/constants/app_constants.dart → licensePublicKeyBase64
 */
import { generateKeyPairSync } from 'node:crypto';

const { publicKey, privateKey } = generateKeyPairSync('ed25519');

const privatePkcs8 = privateKey.export({ type: 'pkcs8', format: 'der' });
// O DER SPKI de Ed25519 tem 44 bytes; os 32 finais são a chave crua.
const publicSpki = publicKey.export({ type: 'spki', format: 'der' });
const publicRaw = publicSpki.subarray(publicSpki.length - 32);

console.log('ED25519_PRIVATE_KEY (secret do worker):');
console.log(privatePkcs8.toString('base64'));
console.log('\nlicensePublicKeyBase64 (AppConstants do app):');
console.log(publicRaw.toString('base64'));
