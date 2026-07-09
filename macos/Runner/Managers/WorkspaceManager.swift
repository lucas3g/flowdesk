import Cocoa
import FlutterMacOS

/// Abre aplicativos por bundle id (usado ao aplicar workspaces) e notifica
/// o Flutter quando qualquer app é aberto no macOS (rules engine).
final class WorkspaceManager: NSObject, FlutterStreamHandler {
  private var eventSink: FlutterEventSink?

  override init() {
    super.init()
    NSWorkspace.shared.notificationCenter.addObserver(
      self,
      selector: #selector(appLaunched(_:)),
      name: NSWorkspace.didLaunchApplicationNotification,
      object: nil
    )
  }

  deinit {
    NSWorkspace.shared.notificationCenter.removeObserver(self)
  }

  // MARK: - EventChannel (apps abertos)

  func onListen(
    withArguments arguments: Any?,
    eventSink events: @escaping FlutterEventSink
  ) -> FlutterError? {
    eventSink = events
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    eventSink = nil
    return nil
  }

  @objc private func appLaunched(_ notification: Notification) {
    guard
      let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey]
        as? NSRunningApplication,
      let bundleId = app.bundleIdentifier
    else { return }

    eventSink?([
      "bundleId": bundleId,
      "appName": app.localizedName ?? bundleId,
    ])
  }

  // MARK: - MethodChannel

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "launchApp":
      guard let args = call.arguments as? [String: Any],
        let bundleId = args["bundleId"] as? String, !bundleId.isEmpty
      else {
        result(
          FlutterError(
            code: "invalid_arguments",
            message: "bundleId ausente em launchApp",
            details: nil
          )
        )
        return
      }
      launchApp(bundleId: bundleId, result: result)

    case "isAppRunning":
      let bundleId =
        (call.arguments as? [String: Any])?["bundleId"] as? String ?? ""
      let running = NSWorkspace.shared.runningApplications.contains {
        $0.bundleIdentifier == bundleId
      }
      result(running)

    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func launchApp(bundleId: String, result: @escaping FlutterResult) {
    guard
      let url = NSWorkspace.shared.urlForApplication(
        withBundleIdentifier: bundleId
      )
    else {
      // App não instalado — não é um erro fatal ao aplicar um workspace.
      result(false)
      return
    }

    let configuration = NSWorkspace.OpenConfiguration()
    configuration.activates = false

    NSWorkspace.shared.openApplication(at: url, configuration: configuration) {
      app, error in
      DispatchQueue.main.async {
        result(error == nil && app != nil)
      }
    }
  }
}
