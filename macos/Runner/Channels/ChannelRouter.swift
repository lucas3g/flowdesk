import FlutterMacOS

/// Registra os canais Flutter ↔ macOS e roteia cada chamada para o manager
/// responsável. Mantém o AppDelegate/MainFlutterWindow livres de lógica.
final class ChannelRouter {
  private let permissionManager = PermissionManager()
  private let monitorManager = MonitorManager()
  private let windowManager = WindowManager()
  private let workspaceManager = WorkspaceManager()
  private let shortcutManager = ShortcutManager()
  private let statusBarManager = StatusBarManager()
  private let launchAtLoginManager = LaunchAtLoginManager()
  private let snapManager = SnapManager()

  func register(with messenger: FlutterBinaryMessenger) {
    let permissionsChannel = FlutterMethodChannel(
      name: "flowdesk/permissions",
      binaryMessenger: messenger
    )
    permissionsChannel.setMethodCallHandler { [permissionManager] call, result in
      permissionManager.handle(call, result: result)
    }

    let monitorsChannel = FlutterMethodChannel(
      name: "flowdesk/monitors",
      binaryMessenger: messenger
    )
    monitorsChannel.setMethodCallHandler { [monitorManager] call, result in
      monitorManager.handle(call, result: result)
    }

    let monitorsEventsChannel = FlutterEventChannel(
      name: "flowdesk/monitors/events",
      binaryMessenger: messenger
    )
    monitorsEventsChannel.setStreamHandler(monitorManager)

    let windowsChannel = FlutterMethodChannel(
      name: "flowdesk/windows",
      binaryMessenger: messenger
    )
    windowsChannel.setMethodCallHandler { [windowManager] call, result in
      windowManager.handle(call, result: result)
    }

    let workspaceChannel = FlutterMethodChannel(
      name: "flowdesk/workspace",
      binaryMessenger: messenger
    )
    workspaceChannel.setMethodCallHandler { [workspaceManager] call, result in
      workspaceManager.handle(call, result: result)
    }

    let workspaceEventsChannel = FlutterEventChannel(
      name: "flowdesk/workspace/events",
      binaryMessenger: messenger
    )
    workspaceEventsChannel.setStreamHandler(workspaceManager)

    let shortcutsChannel = FlutterMethodChannel(
      name: "flowdesk/shortcuts",
      binaryMessenger: messenger
    )
    shortcutsChannel.setMethodCallHandler { [shortcutManager] call, result in
      shortcutManager.handle(call, result: result)
    }

    let shortcutsEventsChannel = FlutterEventChannel(
      name: "flowdesk/shortcuts/events",
      binaryMessenger: messenger
    )
    shortcutsEventsChannel.setStreamHandler(shortcutManager)

    // Canal do app: menu bar/Dock (StatusBarManager), login (LaunchAtLogin)
    // e encaixe magnético (SnapManager).
    let appChannel = FlutterMethodChannel(
      name: "flowdesk/app",
      binaryMessenger: messenger
    )
    appChannel.setMethodCallHandler {
      [statusBarManager, launchAtLoginManager, snapManager] call, result in
      switch call.method {
      case "setLaunchAtLogin":
        launchAtLoginManager.handle(call, result: result)
      case "setMagneticSnap", "setLayoutSnapRegions", "setSnapExcludedApps":
        snapManager.handle(call, result: result)
      default:
        statusBarManager.handle(call, result: result)
      }
    }

    let appEventsChannel = FlutterEventChannel(
      name: "flowdesk/app/events",
      binaryMessenger: messenger
    )
    appEventsChannel.setStreamHandler(statusBarManager)
  }
}
