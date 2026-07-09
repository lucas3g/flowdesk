import FlutterMacOS
import ServiceManagement

/// Registra o FlowDesk para iniciar junto com o macOS (SMAppService).
final class LaunchAtLoginManager {
  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "setLaunchAtLogin":
      let enabled =
        (call.arguments as? [String: Any])?["enabled"] as? Bool ?? false
      if #available(macOS 13.0, *) {
        do {
          if enabled {
            try SMAppService.mainApp.register()
          } else {
            try SMAppService.mainApp.unregister()
          }
          result(true)
        } catch {
          result(false)
        }
      } else {
        // SMAppService exige macOS 13+; versões antigas não são suportadas.
        result(false)
      }

    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
