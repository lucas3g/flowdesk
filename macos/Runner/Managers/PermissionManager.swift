import Cocoa
import FlutterMacOS

/// Consulta e solicita as permissões do macOS exigidas pelo FlowDesk,
/// e abre as seções correspondentes das Ajustes do Sistema.
final class PermissionManager {
  private let accessibility = AccessibilityManager()

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getStatus":
      result([
        "accessibility": accessibility.isTrusted(),
        "screenRecording": CGPreflightScreenCaptureAccess(),
      ])

    case "requestAccessibility":
      result(accessibility.requestTrust())

    case "requestScreenRecording":
      result(CGRequestScreenCaptureAccess())

    case "openSystemSettings":
      let arguments = call.arguments as? [String: Any]
      let section = arguments?["section"] as? String ?? "accessibility"
      openSystemSettings(section: section)
      result(nil)

    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func openSystemSettings(section: String) {
    let urlString: String
    switch section {
    case "screenRecording":
      urlString =
        "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture"
    case "automation":
      urlString =
        "x-apple.systempreferences:com.apple.preference.security?Privacy_Automation"
    default:
      urlString =
        "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"
    }

    if let url = URL(string: urlString) {
      NSWorkspace.shared.open(url)
    }
  }
}
