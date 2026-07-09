import Cocoa
import FlutterMacOS

/// API privada usada por gerenciadores de janela (Rectangle, yabai…) para
/// obter o CGWindowID de um AXUIElement — assim janelas minimizadas
/// (ausentes do CGWindowList on-screen) compartilham o mesmo id.
@_silgen_name("_AXUIElementGetWindow")
private func _AXUIElementGetWindow(
  _ element: AXUIElement,
  _ identifier: UnsafeMutablePointer<CGWindowID>
) -> AXError

/// Lista as janelas visíveis (CGWindowList) e as manipula via Accessibility
/// API (AXUIElement): mover, redimensionar e trazer para frente.
///
/// Coordenadas: sistema global do CoreGraphics (origem no canto superior
/// esquerdo do monitor principal) — o mesmo usado pelo MonitorManager.
final class WindowManager {
  private let accessibility = AccessibilityManager()
  private let iconCache = NSCache<NSNumber, NSData>()

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getWindows":
      result(windowsPayload())

    case "setWindowFrame":
      guard accessibility.isTrusted() else {
        result(accessibilityDeniedError())
        return
      }
      guard let args = call.arguments as? [String: Any],
        let pid = args["pid"] as? Int,
        let windowId = args["id"] as? Int,
        let x = args["x"] as? Double,
        let y = args["y"] as? Double,
        let width = args["width"] as? Double,
        let height = args["height"] as? Double
      else {
        result(invalidArgumentsError(call.method))
        return
      }
      let frame = CGRect(x: x, y: y, width: width, height: height)
      result(setFrame(pid: pid_t(pid), windowId: windowId, frame: frame))

    case "focusWindow":
      guard accessibility.isTrusted() else {
        result(accessibilityDeniedError())
        return
      }
      guard let args = call.arguments as? [String: Any],
        let pid = args["pid"] as? Int,
        let windowId = args["id"] as? Int
      else {
        result(invalidArgumentsError(call.method))
        return
      }
      result(focus(pid: pid_t(pid), windowId: windowId))

    default:
      result(FlutterMethodNotImplemented)
    }
  }

  // MARK: - Listagem (CGWindowList)

  private func windowsPayload() -> [[String: Any]] {
    guard
      let info = CGWindowListCopyWindowInfo(
        [.optionOnScreenOnly, .excludeDesktopElements],
        kCGNullWindowID
      ) as? [[String: Any]]
    else { return [] }

    let screens = screenRectsCG()
    let ownPid = ProcessInfo.processInfo.processIdentifier
    let frontPid = NSWorkspace.shared.frontmostApplication?.processIdentifier
    let trusted = accessibility.isTrusted()

    var payload: [[String: Any]] = []
    var seenIds = Set<Int>()
    // Cache por processo dos títulos obtidos via AX (fallback quando
    // kCGWindowName vem vazio por falta de Gravação de Tela).
    var axTitleCache: [pid_t: [Int: String]] = [:]

    for window in info {
      guard
        let layer = window[kCGWindowLayer as String] as? Int, layer == 0,
        let pid = window[kCGWindowOwnerPID as String] as? Int,
        pid != ownPid,
        let windowId = window[kCGWindowNumber as String] as? Int,
        let boundsDict = window[kCGWindowBounds as String] as? NSDictionary,
        let bounds = CGRect(dictionaryRepresentation: boundsDict),
        bounds.width >= 80, bounds.height >= 60
      else { continue }

      let app = NSRunningApplication(processIdentifier: pid_t(pid))
      let ownerName = window[kCGWindowOwnerName as String] as? String ?? "App"
      seenIds.insert(windowId)

      // kCGWindowName exige a permissão de Gravação de Tela; sem ela vem
      // vazio e o título é buscado via Accessibility (permissão que o app
      // já usa para mover janelas).
      var title = window[kCGWindowName as String] as? String ?? ""
      if title.isEmpty && trusted {
        let ownerPid = pid_t(pid)
        if axTitleCache[ownerPid] == nil {
          axTitleCache[ownerPid] = axTitlesByWindowId(pid: ownerPid)
        }
        title = axTitleCache[ownerPid]?[windowId] ?? ""
      }

      payload.append([
        "id": windowId,
        "pid": pid,
        "appName": app?.localizedName ?? ownerName,
        "bundleId": app?.bundleIdentifier ?? "",
        "title": title,
        "x": bounds.origin.x,
        "y": bounds.origin.y,
        "width": bounds.width,
        "height": bounds.height,
        "monitorId": monitorId(for: bounds, screens: screens),
        "isFocused": pid == Int(frontPid ?? -1),
        "isMinimized": false,
        "icon": iconPNG(for: app, pid: pid)
          ?? FlutterStandardTypedData(bytes: Data()),
      ])
    }

    // Complementa com janelas minimizadas (fora do CGWindowList on-screen),
    // obtidas via Accessibility API, para que possam ser posicionadas.
    if accessibility.isTrusted() {
      payload.append(
        contentsOf: minimizedWindows(
          screens: screens,
          ownPid: ownPid,
          seenIds: seenIds
        )
      )
    }

    return payload
  }

  /// Janelas minimizadas dos apps em execução, via AXUIElement.
  private func minimizedWindows(
    screens: [(id: Int, rect: CGRect)],
    ownPid: Int32,
    seenIds: Set<Int>
  ) -> [[String: Any]] {
    var result: [[String: Any]] = []

    for app in NSWorkspace.shared.runningApplications
    where app.activationPolicy == .regular
      && app.processIdentifier != ownPid {
      let axApp = AXUIElementCreateApplication(app.processIdentifier)
      var value: CFTypeRef?
      guard
        AXUIElementCopyAttributeValue(
          axApp, kAXWindowsAttribute as CFString, &value) == .success,
        let windows = value as? [AXUIElement]
      else { continue }

      for window in windows {
        var minimizedRef: CFTypeRef?
        guard
          AXUIElementCopyAttributeValue(
            window, kAXMinimizedAttribute as CFString, &minimizedRef)
            == .success,
          (minimizedRef as? Bool) == true
        else { continue }

        var windowId: CGWindowID = 0
        guard _AXUIElementGetWindow(window, &windowId) == .success,
          !seenIds.contains(Int(windowId))
        else { continue }

        let frame = axFrame(of: window) ?? .zero
        var titleRef: CFTypeRef?
        AXUIElementCopyAttributeValue(
          window, kAXTitleAttribute as CFString, &titleRef)

        result.append([
          "id": Int(windowId),
          "pid": Int(app.processIdentifier),
          "appName": app.localizedName ?? "App",
          "bundleId": app.bundleIdentifier ?? "",
          "title": (titleRef as? String) ?? "",
          "x": frame.origin.x,
          "y": frame.origin.y,
          "width": max(frame.width, 80),
          "height": max(frame.height, 60),
          "monitorId": monitorId(for: frame, screens: screens),
          "isFocused": false,
          "isMinimized": true,
          "icon": iconPNG(for: app, pid: Int(app.processIdentifier))
            ?? FlutterStandardTypedData(bytes: Data()),
        ])
      }
    }

    return result
  }

  /// Títulos das janelas de um processo via Accessibility, indexados pelo
  /// CGWindowID — fallback para quando kCGWindowName exige Gravação de Tela.
  private func axTitlesByWindowId(pid: pid_t) -> [Int: String] {
    let app = AXUIElementCreateApplication(pid)
    var value: CFTypeRef?
    guard
      AXUIElementCopyAttributeValue(app, kAXWindowsAttribute as CFString, &value)
        == .success,
      let windows = value as? [AXUIElement]
    else { return [:] }

    var titles: [Int: String] = [:]
    for window in windows {
      var id: CGWindowID = 0
      guard _AXUIElementGetWindow(window, &id) == .success else { continue }
      var titleRef: CFTypeRef?
      AXUIElementCopyAttributeValue(
        window, kAXTitleAttribute as CFString, &titleRef)
      if let title = titleRef as? String, !title.isEmpty {
        titles[Int(id)] = title
      }
    }
    return titles
  }

  /// Retângulos dos monitores em coordenadas CG (origem superior esquerda).
  private func screenRectsCG() -> [(id: Int, rect: CGRect)] {
    guard let primary = NSScreen.screens.first else { return [] }
    let globalHeight = primary.frame.maxY

    return NSScreen.screens.map { screen in
      let displayId =
        (screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")]
          as? NSNumber)?.intValue ?? 0
      let frame = screen.frame
      let cgRect = CGRect(
        x: frame.origin.x,
        y: globalHeight - frame.maxY,
        width: frame.width,
        height: frame.height
      )
      return (id: displayId, rect: cgRect)
    }
  }

  /// Monitor com a maior área de interseção com a janela.
  private func monitorId(
    for bounds: CGRect,
    screens: [(id: Int, rect: CGRect)]
  ) -> Int {
    var bestId = screens.first?.id ?? 0
    var bestArea: CGFloat = 0
    for screen in screens {
      let intersection = screen.rect.intersection(bounds)
      let area = intersection.width * intersection.height
      if area > bestArea {
        bestArea = area
        bestId = screen.id
      }
    }
    return bestId
  }

  private func iconPNG(
    for app: NSRunningApplication?,
    pid: Int
  ) -> FlutterStandardTypedData? {
    if let cached = iconCache.object(forKey: NSNumber(value: pid)) {
      return FlutterStandardTypedData(bytes: cached as Data)
    }
    guard let icon = app?.icon else { return nil }

    let size = NSSize(width: 32, height: 32)
    let resized = NSImage(size: size)
    resized.lockFocus()
    icon.draw(in: NSRect(origin: .zero, size: size))
    resized.unlockFocus()

    guard let tiff = resized.tiffRepresentation,
      let rep = NSBitmapImageRep(data: tiff),
      let png = rep.representation(using: .png, properties: [:])
    else { return nil }

    iconCache.setObject(png as NSData, forKey: NSNumber(value: pid))
    return FlutterStandardTypedData(bytes: png)
  }

  // MARK: - Manipulação (AXUIElement)

  private func setFrame(pid: pid_t, windowId: Int, frame: CGRect) -> Bool {
    guard let window = axWindow(pid: pid, windowId: windowId) else {
      return false
    }

    // 1. Restaura a janela se estiver minimizada — janelas minimizadas
    // não aceitam mudança de posição/tamanho.
    var minimizedRef: CFTypeRef?
    if AXUIElementCopyAttributeValue(
      window, kAXMinimizedAttribute as CFString, &minimizedRef) == .success,
      (minimizedRef as? Bool) == true {
      AXUIElementSetAttributeValue(
        window,
        kAXMinimizedAttribute as CFString,
        kCFBooleanFalse
      )
    }

    // 2. Traz o app e a janela para frente (janelas atrás de outras
    // precisam ser levantadas para o reposicionamento ser visível).
    NSRunningApplication(processIdentifier: pid)?
      .activate(options: [.activateIgnoringOtherApps])
    AXUIElementPerformAction(window, kAXRaiseAction as CFString)

    var position = frame.origin
    var size = CGSize(width: frame.width, height: frame.height)

    guard let positionValue = AXValueCreate(.cgPoint, &position),
      let sizeValue = AXValueCreate(.cgSize, &size)
    else { return false }

    // 3. Sequência tamanho → posição → tamanho → posição: ao mover entre
    // monitores de escalas diferentes, o primeiro tamanho pode ser
    // limitado pela tela de origem; após a posição levar a janela ao
    // monitor de destino, o segundo tamanho aplica o valor correto, e a
    // posição final corrige apps que reancoram ao redimensionar.
    AXUIElementSetAttributeValue(window, kAXSizeAttribute as CFString, sizeValue)
    AXUIElementSetAttributeValue(
      window, kAXPositionAttribute as CFString, positionValue)
    AXUIElementSetAttributeValue(window, kAXSizeAttribute as CFString, sizeValue)
    let status = AXUIElementSetAttributeValue(
      window,
      kAXPositionAttribute as CFString,
      positionValue
    )

    // 4. Verificação: o macOS pode clampar tamanho/posição usando a tela em
    // que a janela estava no momento de cada chamada. Com a janela já no
    // destino, reaplica até o frame convergir.
    for _ in 0..<2 {
      guard let current = axFrame(of: window),
        abs(current.origin.x - frame.origin.x) > 2
          || abs(current.origin.y - frame.origin.y) > 2
          || abs(current.width - frame.width) > 2
          || abs(current.height - frame.height) > 2
      else { break }
      AXUIElementSetAttributeValue(
        window, kAXSizeAttribute as CFString, sizeValue)
      AXUIElementSetAttributeValue(
        window, kAXPositionAttribute as CFString, positionValue)
    }
    return status == .success
  }

  private func focus(pid: pid_t, windowId: Int) -> Bool {
    guard let window = axWindow(pid: pid, windowId: windowId) else {
      return false
    }
    AXUIElementPerformAction(window, kAXRaiseAction as CFString)
    NSRunningApplication(processIdentifier: pid)?
      .activate(options: [.activateIgnoringOtherApps])
    return true
  }

  /// Localiza o AXUIElement da janela pelo CGWindowID (confiável, inclusive
  /// para janelas minimizadas); recai no matching por bounds se necessário.
  private func axWindow(pid: pid_t, windowId: Int) -> AXUIElement? {
    let app = AXUIElementCreateApplication(pid)
    var value: CFTypeRef?
    guard
      AXUIElementCopyAttributeValue(app, kAXWindowsAttribute as CFString, &value)
        == .success,
      let windows = value as? [AXUIElement], !windows.isEmpty
    else { return nil }

    // Casa pelo próprio id da janela.
    for window in windows {
      var id: CGWindowID = 0
      if _AXUIElementGetWindow(window, &id) == .success, Int(id) == windowId {
        return window
      }
    }

    // Fallback: compara o frame do AX com os bounds do CGWindowList.
    guard let cgBounds = currentBounds(windowId: windowId) else {
      return windows.first
    }
    for window in windows {
      if let frame = axFrame(of: window),
        abs(frame.origin.x - cgBounds.origin.x) <= 2,
        abs(frame.origin.y - cgBounds.origin.y) <= 2,
        abs(frame.width - cgBounds.width) <= 2,
        abs(frame.height - cgBounds.height) <= 2 {
        return window
      }
    }
    return windows.first
  }

  private func currentBounds(windowId: Int) -> CGRect? {
    guard
      let info = CGWindowListCopyWindowInfo(
        [.optionIncludingWindow],
        CGWindowID(windowId)
      ) as? [[String: Any]],
      let window = info.first,
      let boundsDict = window[kCGWindowBounds as String] as? NSDictionary
    else { return nil }
    return CGRect(dictionaryRepresentation: boundsDict)
  }

  private func axFrame(of window: AXUIElement) -> CGRect? {
    var positionRef: CFTypeRef?
    var sizeRef: CFTypeRef?
    guard
      AXUIElementCopyAttributeValue(
        window, kAXPositionAttribute as CFString, &positionRef) == .success,
      AXUIElementCopyAttributeValue(
        window, kAXSizeAttribute as CFString, &sizeRef) == .success
    else { return nil }

    var position = CGPoint.zero
    var size = CGSize.zero
    // swiftlint:disable force_cast
    AXValueGetValue(positionRef as! AXValue, .cgPoint, &position)
    AXValueGetValue(sizeRef as! AXValue, .cgSize, &size)
    // swiftlint:enable force_cast
    return CGRect(origin: position, size: size)
  }

  // MARK: - Erros

  private func accessibilityDeniedError() -> FlutterError {
    FlutterError(
      code: "accessibility_denied",
      message: "Permissão de Acessibilidade não concedida",
      details: nil
    )
  }

  private func invalidArgumentsError(_ method: String) -> FlutterError {
    FlutterError(
      code: "invalid_arguments",
      message: "Argumentos inválidos para \(method)",
      details: nil
    )
  }
}
