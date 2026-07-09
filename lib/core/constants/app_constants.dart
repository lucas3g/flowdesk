/// Constantes globais do aplicativo.
abstract final class AppConstants {
  static const String appName = 'FlowDesk';

  /// Nomes dos MethodChannels/EventChannels (espelhados no lado Swift).
  static const String windowsChannel = 'flowdesk/windows';
  static const String monitorsChannel = 'flowdesk/monitors';
  static const String monitorsEventsChannel = 'flowdesk/monitors/events';
  static const String permissionsChannel = 'flowdesk/permissions';
  static const String shortcutsChannel = 'flowdesk/shortcuts';
  static const String shortcutsEventsChannel = 'flowdesk/shortcuts/events';
  static const String workspaceChannel = 'flowdesk/workspace';
  static const String workspaceEventsChannel = 'flowdesk/workspace/events';
  static const String appChannel = 'flowdesk/app';
  static const String appEventsChannel = 'flowdesk/app/events';

  /// Licenciamento premium (Paddle + API de licenças em `backend/`).
  ///
  /// [licenseApiBaseUrl] aponta para o worker que recebe os webhooks do
  /// Paddle e emite entitlements assinados; [checkoutUrl] é o link de
  /// checkout hospedado criado no dashboard do Paddle; a chave pública
  /// verifica a assinatura Ed25519 dos entitlements (par gerado por
  /// `backend/paddle-licenses/scripts/generate-keys.mjs`).
  static const String licenseApiBaseUrl =
      'https://flowdesk-licenses.example.workers.dev';
  static const String checkoutUrl =
      'https://pay.paddle.io/hsc_SUBSTITUA_PELO_SEU_LINK';
  static const String licensePublicKeyBase64 =
      'SUBSTITUA_PELA_CHAVE_PUBLICA_ED25519_BASE64';

  /// Tolerância offline: por quantos dias após `premiumUntil` o premium
  /// continua ativo sem conseguir revalidar com o servidor.
  static const int licenseGraceDays = 14;

  /// Idade máxima da última validação antes de tentar revalidar em
  /// segundo plano.
  static const Duration licenseRevalidationInterval = Duration(days: 3);
}
