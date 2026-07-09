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
}
