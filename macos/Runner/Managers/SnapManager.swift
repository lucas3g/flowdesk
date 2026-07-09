import Cocoa
import FlutterMacOS

/// Mesma API privada usada pelo WindowManager para obter o CGWindowID
/// de um AXUIElement.
@_silgen_name("_AXUIElementGetWindow")
private func _SnapAXUIElementGetWindow(
  _ element: AXUIElement,
  _ identifier: UnsafeMutablePointer<CGWindowID>
) -> AXError

/// Encaixe magnético: ao arrastar uma janela de outro app até uma borda ou
/// canto do monitor, mostra um overlay sugerindo a região (metade, quarto ou
/// tela cheia) e aplica o frame via Accessibility ao soltar o mouse.
///
/// O rastreamento usa monitores globais de NSEvent (mouseDown/Dragged/Up),
/// que só recebem eventos de outros apps — exatamente o alvo do recurso.
final class SnapManager {
  private let accessibility = AccessibilityManager()

  private var monitors: [Any] = []
  private var overlay: SnapOverlayWindow?

  // Estado do arrasto em andamento.
  private var draggedWindow: AXUIElement?
  private var dragStartOrigin: CGPoint?
  private var windowIsMoving = false
  /// Região sugerida (coordenadas Cocoa, origem inferior esquerda).
  private var suggestedRegion: NSRect?

  /// Distância máxima do cursor à borda física para ativar uma sugestão.
  private let edgeThreshold: CGFloat = 10
  /// Extensão da zona de canto ao longo da borda (gera quartos de tela).
  private let cornerZone: CGFloat = 140

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "setMagneticSnap":
      guard let args = call.arguments as? [String: Any],
        let enabled = args["enabled"] as? Bool
      else {
        result(
          FlutterError(
            code: "invalid_arguments",
            message: "Argumentos inválidos para setMagneticSnap",
            details: nil
          ))
        return
      }
      if enabled { enable() } else { disable() }
      result(true)

    default:
      result(FlutterMethodNotImplemented)
    }
  }

  // MARK: - Ativação

  private func enable() {
    guard monitors.isEmpty, accessibility.isTrusted() else { return }

    monitors.append(
      NSEvent.addGlobalMonitorForEvents(matching: .leftMouseDown) {
        [weak self] _ in self?.beginTracking()
      } as Any)
    monitors.append(
      NSEvent.addGlobalMonitorForEvents(matching: .leftMouseDragged) {
        [weak self] _ in self?.updateTracking()
      } as Any)
    monitors.append(
      NSEvent.addGlobalMonitorForEvents(matching: .leftMouseUp) {
        [weak self] _ in self?.endTracking()
      } as Any)
  }

  private func disable() {
    monitors.forEach { NSEvent.removeMonitor($0) }
    monitors.removeAll()
    resetDragState()
  }

  // MARK: - Ciclo do arrasto

  /// mouseDown: captura a janela sob o cursor e sua posição inicial.
  private func beginTracking() {
    resetDragState()

    let cgPoint = cgLocation(of: NSEvent.mouseLocation)
    guard let window = axWindow(atCG: cgPoint) else { return }

    var pid: pid_t = 0
    guard AXUIElementGetPid(window, &pid) == .success,
      pid != ProcessInfo.processInfo.processIdentifier
    else { return }

    draggedWindow = window
    dragStartOrigin = axPosition(of: window)
  }

  /// mouseDragged: confirma que a janela está de fato se movendo (e não é
  /// um arrasto de conteúdo/seleção) e atualiza a sugestão de região.
  private func updateTracking() {
    guard let window = draggedWindow else { return }

    if !windowIsMoving {
      guard let start = dragStartOrigin,
        let current = axPosition(of: window),
        abs(current.x - start.x) > 4 || abs(current.y - start.y) > 4
      else { return }
      windowIsMoving = true
    }

    let mouse = NSEvent.mouseLocation
    guard let screen = NSScreen.screens.first(where: {
      NSMouseInRect(mouse, $0.frame, false)
    }) else {
      hideSuggestion()
      return
    }

    if let region = snapRegion(for: mouse, on: screen) {
      showSuggestion(region)
    } else {
      hideSuggestion()
    }
  }

  /// mouseUp: aplica a região sugerida, se houver.
  private func endTracking() {
    if let window = draggedWindow, let region = suggestedRegion,
      windowIsMoving {
      apply(cocoaFrame: region, to: window)
    }
    resetDragState()
  }

  private func resetDragState() {
    draggedWindow = nil
    dragStartOrigin = nil
    windowIsMoving = false
    hideSuggestion()
  }

  // MARK: - Zonas de encaixe

  /// Região sugerida para o cursor em `point` (coordenadas Cocoa), ou nil
  /// se o cursor não está próximo de nenhuma borda.
  ///
  /// Bordas esquerda/direita geram metades; cantos geram quartos; borda
  /// superior central maximiza. A borda inferior central é ignorada para
  /// não disparar sugestões na região do Dock.
  private func snapRegion(for point: NSPoint, on screen: NSScreen) -> NSRect? {
    let frame = screen.frame
    let area = screen.visibleFrame

    let nearLeft = point.x <= frame.minX + edgeThreshold
    let nearRight = point.x >= frame.maxX - edgeThreshold
    let nearTop = point.y >= frame.maxY - edgeThreshold
    let nearBottom = point.y <= frame.minY + edgeThreshold

    let halfWidth = area.width / 2
    let halfHeight = area.height / 2

    let topHalfY = area.minY + halfHeight

    if nearLeft {
      if point.y >= frame.maxY - cornerZone {
        return NSRect(x: area.minX, y: topHalfY, width: halfWidth, height: halfHeight)
      }
      if point.y <= frame.minY + cornerZone {
        return NSRect(x: area.minX, y: area.minY, width: halfWidth, height: halfHeight)
      }
      return NSRect(x: area.minX, y: area.minY, width: halfWidth, height: area.height)
    }

    if nearRight {
      let rightX = area.minX + halfWidth
      if point.y >= frame.maxY - cornerZone {
        return NSRect(x: rightX, y: topHalfY, width: halfWidth, height: halfHeight)
      }
      if point.y <= frame.minY + cornerZone {
        return NSRect(x: rightX, y: area.minY, width: halfWidth, height: halfHeight)
      }
      return NSRect(x: rightX, y: area.minY, width: halfWidth, height: area.height)
    }

    if nearTop {
      if point.x <= frame.minX + cornerZone {
        return NSRect(x: area.minX, y: topHalfY, width: halfWidth, height: halfHeight)
      }
      if point.x >= frame.maxX - cornerZone {
        return NSRect(
          x: area.minX + halfWidth, y: topHalfY,
          width: halfWidth, height: halfHeight)
      }
      return area
    }

    if nearBottom {
      if point.x <= frame.minX + cornerZone {
        return NSRect(x: area.minX, y: area.minY, width: halfWidth, height: halfHeight)
      }
      if point.x >= frame.maxX - cornerZone {
        return NSRect(
          x: area.minX + halfWidth, y: area.minY,
          width: halfWidth, height: halfHeight)
      }
    }

    return nil
  }

  // MARK: - Overlay

  private func showSuggestion(_ region: NSRect) {
    if region == suggestedRegion { return }
    suggestedRegion = region

    if overlay == nil { overlay = SnapOverlayWindow() }
    overlay?.show(at: region)
  }

  private func hideSuggestion() {
    suggestedRegion = nil
    overlay?.orderOut(nil)
  }

  // MARK: - Aplicação do frame

  /// Converte a região (Cocoa) para coordenadas CG e aplica via AX,
  /// reaplicando uma vez caso o sistema clampe tamanho ou posição.
  private func apply(cocoaFrame: NSRect, to window: AXUIElement) {
    guard let primary = NSScreen.screens.first else { return }
    let globalHeight = primary.frame.maxY

    var position = CGPoint(
      x: cocoaFrame.origin.x,
      y: globalHeight - cocoaFrame.maxY
    )
    var size = CGSize(width: cocoaFrame.width, height: cocoaFrame.height)

    guard let positionValue = AXValueCreate(.cgPoint, &position),
      let sizeValue = AXValueCreate(.cgSize, &size)
    else { return }

    for _ in 0..<2 {
      AXUIElementSetAttributeValue(
        window, kAXPositionAttribute as CFString, positionValue)
      AXUIElementSetAttributeValue(
        window, kAXSizeAttribute as CFString, sizeValue)

      guard let current = axFrame(of: window),
        abs(current.origin.x - position.x) > 2
          || abs(current.origin.y - position.y) > 2
          || abs(current.width - size.width) > 2
          || abs(current.height - size.height) > 2
      else { break }
    }
  }

  // MARK: - Utilitários AX

  /// Janela AX sob o ponto (coordenadas CG), via hit-test do sistema.
  private func axWindow(atCG point: CGPoint) -> AXUIElement? {
    let systemWide = AXUIElementCreateSystemWide()
    var elementRef: AXUIElement?
    guard
      AXUIElementCopyElementAtPosition(
        systemWide, Float(point.x), Float(point.y), &elementRef) == .success,
      var element = elementRef
    else { return nil }

    // Sobe na hierarquia até encontrar o elemento com papel de janela.
    for _ in 0..<16 {
      var roleRef: CFTypeRef?
      if AXUIElementCopyAttributeValue(
        element, kAXRoleAttribute as CFString, &roleRef) == .success,
        (roleRef as? String) == kAXWindowRole {
        return element
      }
      var parentRef: CFTypeRef?
      guard
        AXUIElementCopyAttributeValue(
          element, kAXParentAttribute as CFString, &parentRef) == .success,
        let parent = parentRef
      else { break }
      element = (parent as! AXUIElement)  // swiftlint:disable:this force_cast
    }

    // Fallback: atributo de janela do próprio elemento.
    var windowRef: CFTypeRef?
    if AXUIElementCopyAttributeValue(
      element, kAXWindowAttribute as CFString, &windowRef) == .success,
      let window = windowRef {
      return (window as! AXUIElement)  // swiftlint:disable:this force_cast
    }
    return nil
  }

  private func axPosition(of window: AXUIElement) -> CGPoint? {
    axFrame(of: window)?.origin
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

  /// Converte um ponto Cocoa (origem inferior esquerda do monitor principal)
  /// para CG (origem superior esquerda).
  private func cgLocation(of cocoaPoint: NSPoint) -> CGPoint {
    let globalHeight = NSScreen.screens.first?.frame.maxY ?? 0
    return CGPoint(x: cocoaPoint.x, y: globalHeight - cocoaPoint.y)
  }
}

/// Janela transparente que destaca a região sugerida durante o arrasto.
private final class SnapOverlayWindow: NSWindow {
  init() {
    super.init(
      contentRect: .zero,
      styleMask: .borderless,
      backing: .buffered,
      defer: false
    )
    isOpaque = false
    backgroundColor = .clear
    hasShadow = false
    ignoresMouseEvents = true
    isReleasedWhenClosed = false
    level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.draggingWindow)))
    collectionBehavior = [.canJoinAllSpaces, .transient]

    let highlight = NSView()
    highlight.wantsLayer = true
    highlight.layer?.cornerRadius = 10
    highlight.layer?.borderWidth = 2
    highlight.layer?.backgroundColor =
      NSColor.controlAccentColor.withAlphaComponent(0.22).cgColor
    highlight.layer?.borderColor =
      NSColor.controlAccentColor.withAlphaComponent(0.9).cgColor
    contentView = highlight
  }

  /// Exibe o destaque na região indicada (coordenadas Cocoa), com uma
  /// pequena margem para o realce não colar nas bordas.
  func show(at region: NSRect) {
    setFrame(region.insetBy(dx: 4, dy: 4), display: true)
    orderFrontRegardless()
  }
}
