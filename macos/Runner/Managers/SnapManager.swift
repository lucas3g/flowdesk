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

  // Modos ativos: bordas (magnético) e/ou regiões do layout aplicado.
  private var magneticSnapEnabled = false
  private var layoutSnapEnabled = false
  /// Zonas de encaixe do layout (coordenadas CG, origem superior esquerda).
  private var layoutRegions: [CGRect] = []
  /// Overlays (um por monitor) que desenham todas as zonas durante o arrasto.
  private var zoneWindows: [LayoutZonesOverlayWindow] = []
  private var zonesVisible = false
  /// Apps — ou instâncias específicas (CGWindowID) — que não participam do
  /// encaixe ao arrastar. windowId 0 exclui o app inteiro.
  private var excludedApps: [(bundleId: String, windowId: Int)] = []

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
      magneticSnapEnabled = enabled
      refreshMonitors()
      result(true)

    case "setLayoutSnapRegions":
      guard let args = call.arguments as? [String: Any],
        let enabled = args["enabled"] as? Bool,
        let rawRegions = args["regions"] as? [[String: Any]]
      else {
        result(
          FlutterError(
            code: "invalid_arguments",
            message: "Argumentos inválidos para setLayoutSnapRegions",
            details: nil
          ))
        return
      }
      layoutRegions = rawRegions.compactMap { raw in
        guard let x = raw["x"] as? Double,
          let y = raw["y"] as? Double,
          let width = raw["width"] as? Double,
          let height = raw["height"] as? Double
        else { return nil }
        return CGRect(x: x, y: y, width: width, height: height)
      }
      layoutSnapEnabled = enabled && !layoutRegions.isEmpty
      refreshMonitors()
      result(true)

    case "setSnapExcludedApps":
      guard let args = call.arguments as? [String: Any],
        let apps = args["apps"] as? [[String: Any]]
      else {
        result(
          FlutterError(
            code: "invalid_arguments",
            message: "Argumentos inválidos para setSnapExcludedApps",
            details: nil
          ))
        return
      }
      excludedApps = apps.compactMap { raw in
        guard let bundleId = raw["bundleId"] as? String else { return nil }
        return (bundleId: bundleId, windowId: raw["windowId"] as? Int ?? 0)
      }
      result(true)

    default:
      result(FlutterMethodNotImplemented)
    }
  }

  /// Liga/desliga os monitores globais de mouse conforme algum modo ativo.
  private func refreshMonitors() {
    if magneticSnapEnabled || layoutSnapEnabled {
      enable()
    } else {
      disable()
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

    // Apps/instâncias excluídos arrastam livres: nenhum overlay ou encaixe.
    if let bundleId = NSRunningApplication(processIdentifier: pid)?
      .bundleIdentifier,
      isExcluded(bundleId: bundleId, window: window) {
      return
    }

    draggedWindow = window
    dragStartOrigin = axPosition(of: window)
  }

  /// A janela está excluída quando há uma entrada do app com windowId 0
  /// (app inteiro) ou com o CGWindowID exato desta janela.
  private func isExcluded(bundleId: String, window: AXUIElement) -> Bool {
    let entries = excludedApps.filter { $0.bundleId == bundleId }
    if entries.isEmpty { return false }
    if entries.contains(where: { $0.windowId == 0 }) { return true }

    var windowId: CGWindowID = 0
    guard _SnapAXUIElementGetWindow(window, &windowId) == .success,
      windowId != 0
    else { return false }
    return entries.contains { $0.windowId == Int(windowId) }
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

    // Modo regiões do layout: mostra todas as zonas e sugere a que contém
    // o cursor. Tem prioridade sobre o modo de bordas.
    if layoutSnapEnabled && !layoutRegions.isEmpty {
      showZones()
      let cgMouse = cgLocation(of: mouse)
      if let region = layoutRegions.first(where: { $0.contains(cgMouse) }) {
        showSuggestion(cocoaRect(fromCG: region))
      } else {
        hideSuggestion()
      }
      return
    }

    guard magneticSnapEnabled,
      let screen = NSScreen.screens.first(where: {
        NSMouseInRect(mouse, $0.frame, false)
      })
    else {
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
    hideZones()
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

  /// Exibe as zonas do layout em todos os monitores que as contêm.
  private func showZones() {
    guard !zonesVisible else { return }
    zonesVisible = true

    for screen in NSScreen.screens {
      let regions = layoutRegions
        .map { cocoaRect(fromCG: $0) }
        .filter { screen.frame.intersects($0) }
      guard !regions.isEmpty else { continue }

      let window = LayoutZonesOverlayWindow()
      window.show(regions: regions, on: screen)
      zoneWindows.append(window)
    }
  }

  private func hideZones() {
    zonesVisible = false
    zoneWindows.forEach { $0.orderOut(nil) }
    zoneWindows.removeAll()
  }

  /// Converte um retângulo CG (origem superior esquerda) para Cocoa
  /// (origem inferior esquerda do monitor principal).
  private func cocoaRect(fromCG rect: CGRect) -> NSRect {
    let globalHeight = NSScreen.screens.first?.frame.maxY ?? 0
    return NSRect(
      x: rect.origin.x,
      y: globalHeight - rect.maxY,
      width: rect.width,
      height: rect.height
    )
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

    // Sequência tamanho → posição → tamanho: apps que reancoram ou clampam
    // em um dos passos convergem com a reaplicação alternada.
    let applyOnce = {
      AXUIElementSetAttributeValue(
        window, kAXSizeAttribute as CFString, sizeValue)
      AXUIElementSetAttributeValue(
        window, kAXPositionAttribute as CFString, positionValue)
      AXUIElementSetAttributeValue(
        window, kAXSizeAttribute as CFString, sizeValue)
    }
    let matchesTarget = { [weak self] () -> Bool in
      guard let current = self?.axFrame(of: window) else { return true }
      return abs(current.origin.x - position.x) <= 2
        && abs(current.origin.y - position.y) <= 2
        && abs(current.width - size.width) <= 2
        && abs(current.height - size.height) <= 2
    }

    applyOnce()
    for _ in 0..<3 where !matchesTarget() {
      applyOnce()
    }

    // Apps com sidebar/drawer (ex.: Mail) clampam o salto direto para o
    // tamanho final; a redução em passos imita o arrasto manual e dá ao app
    // a chance de recolher o drawer no caminho.
    if !matchesTarget() {
      stepResize(to: size, window: window)
      applyOnce()
    }

    // O app ainda pode reacomodar o layout interno instantes depois;
    // reaplica quando essa acomodação termina.
    for delay in [0.25, 0.6] {
      DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
        if !matchesTarget() {
          self?.stepResize(to: size, window: window)
          applyOnce()
        }
      }
    }
  }

  /// Redimensiona em passos de ~120px até o tamanho alvo. Apps com sidebar
  /// colapsável só aceitam larguras menores depois de recolhê-la — o que só
  /// acontece com reduções graduais, como num arrasto manual da borda.
  private func stepResize(to target: CGSize, window: AXUIElement) {
    guard var current = axFrame(of: window)?.size else { return }

    for _ in 0..<40 {
      let doneWidth = abs(current.width - target.width) <= 2
      let doneHeight = abs(current.height - target.height) <= 2
      if doneWidth && doneHeight { return }

      let step: CGFloat = 120
      var next = CGSize(
        width: current.width > target.width
          ? max(target.width, current.width - step)
          : min(target.width, current.width + step),
        height: current.height > target.height
          ? max(target.height, current.height - step)
          : min(target.height, current.height + step)
      )
      guard let value = AXValueCreate(.cgSize, &next) else { return }
      AXUIElementSetAttributeValue(
        window, kAXSizeAttribute as CFString, value)

      guard let updated = axFrame(of: window)?.size else { return }
      // Sem progresso: o app atingiu o mínimo real — não insiste.
      if abs(updated.width - current.width) < 1
        && abs(updated.height - current.height) < 1 {
        return
      }
      current = updated
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

/// Janela transparente que desenha todas as zonas do layout em um monitor
/// durante o arrasto (a zona sob o cursor é destacada pelo SnapOverlayWindow).
private final class LayoutZonesOverlayWindow: NSWindow {
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
  }

  /// Exibe os contornos das regiões (coordenadas Cocoa globais) no monitor.
  func show(regions: [NSRect], on screen: NSScreen) {
    setFrame(screen.frame, display: false)

    let container = NSView(
      frame: NSRect(origin: .zero, size: screen.frame.size))
    container.wantsLayer = true

    for region in regions {
      let local = NSRect(
        x: region.origin.x - screen.frame.origin.x,
        y: region.origin.y - screen.frame.origin.y,
        width: region.width,
        height: region.height
      ).insetBy(dx: 4, dy: 4)

      let zone = NSView(frame: local)
      zone.wantsLayer = true
      zone.layer?.cornerRadius = 10
      zone.layer?.borderWidth = 1.5
      zone.layer?.backgroundColor =
        NSColor.controlAccentColor.withAlphaComponent(0.08).cgColor
      zone.layer?.borderColor =
        NSColor.controlAccentColor.withAlphaComponent(0.5).cgColor
      container.addSubview(zone)
    }

    contentView = container
    orderFrontRegardless()
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
