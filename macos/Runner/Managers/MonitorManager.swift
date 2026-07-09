import Cocoa
import FlutterMacOS

/// Enumera os monitores conectados (NSScreen/CGDisplay) e notifica o Flutter
/// quando telas são conectadas, removidas ou reconfiguradas.
final class MonitorManager: NSObject, FlutterStreamHandler {
  private var eventSink: FlutterEventSink?

  override init() {
    super.init()
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(screensChanged),
      name: NSApplication.didChangeScreenParametersNotification,
      object: nil
    )
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  // MARK: - MethodChannel

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getMonitors":
      result(monitorsPayload())
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  // MARK: - EventChannel (mudanças de configuração de telas)

  func onListen(
    withArguments arguments: Any?,
    eventSink events: @escaping FlutterEventSink
  ) -> FlutterError? {
    eventSink = events
    // Emite o estado atual imediatamente para o assinante não esperar
    // pela primeira mudança.
    events(monitorsPayload())
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    eventSink = nil
    return nil
  }

  @objc private func screensChanged() {
    eventSink?(monitorsPayload())
  }

  // MARK: - Payload

  private func monitorsPayload() -> [[String: Any]] {
    // Altura global usada para converter das coordenadas do AppKit (origem
    // inferior esquerda) para as do CoreGraphics (origem superior esquerda),
    // o sistema usado pelo WindowManager.
    let globalHeight = NSScreen.screens.first?.frame.maxY ?? 0

    return NSScreen.screens.map { screen in
      let displayID =
        (screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")]
          as? NSNumber)?.uint32Value ?? 0
      let mode = CGDisplayCopyDisplayMode(displayID)
      let visible = screen.visibleFrame

      return [
        "id": Int(displayID),
        "name": screen.localizedName,
        "x": screen.frame.origin.x,
        "y": screen.frame.origin.y,
        "width": screen.frame.width,
        "height": screen.frame.height,
        "pixelWidth": mode?.pixelWidth
          ?? Int(screen.frame.width * screen.backingScaleFactor),
        "pixelHeight": mode?.pixelHeight
          ?? Int(screen.frame.height * screen.backingScaleFactor),
        // Área útil (sem menu bar/Dock) em coordenadas CG, usada para
        // maximizar/centralizar janelas.
        "visibleX": visible.origin.x,
        "visibleY": globalHeight - visible.maxY,
        "visibleWidth": visible.width,
        "visibleHeight": visible.height,
        "scale": screen.backingScaleFactor,
        "refreshRate": mode?.refreshRate ?? 0,
        "isPrimary": screen == NSScreen.screens.first,
        "isBuiltIn": CGDisplayIsBuiltin(displayID) != 0,
      ]
    }
  }
}
