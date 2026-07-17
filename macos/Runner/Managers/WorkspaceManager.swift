import ApplicationServices
import Cocoa
import FlutterMacOS

/// Resolve o CGWindowID de um AXUIElement (API privada, estável desde 10.10).
/// Redeclarada aqui pois a versão em WindowManager.swift é privada.
@_silgen_name("_AXUIElementGetWindow")
private func _AXUIElementGetWindow(
  _ element: AXUIElement,
  _ id: UnsafeMutablePointer<CGWindowID>
) -> AXError

/// Callback C do AXObserver — recupera o WorkspaceManager via refcon.
private func axWindowCreatedCallback(
  _ observer: AXObserver,
  _ element: AXUIElement,
  _ notification: CFString,
  _ refcon: UnsafeMutableRawPointer?
) {
  guard let refcon else { return }
  let manager = Unmanaged<WorkspaceManager>.fromOpaque(refcon)
    .takeUnretainedValue()
  manager.windowCreated(element: element)
}

/// Abre aplicativos por bundle id (usado ao aplicar workspaces) e notifica
/// o Flutter quando qualquer app é aberto no macOS (rules engine). Para apps
/// com regra ativa, também observa a criação de novas janelas via AXObserver,
/// emitindo eventos com o windowId específico.
final class WorkspaceManager: NSObject, FlutterStreamHandler {
  private var eventSink: FlutterEventSink?

  /// BundleIds com regra ativa (sincronizados pelo Flutter via setRuleApps).
  private var watchedBundleIds: Set<String> = []

  /// Observers AX registrados, por pid do app observado.
  private var observers: [pid_t: AXObserver] = [:]

  override init() {
    super.init()
    let center = NSWorkspace.shared.notificationCenter
    center.addObserver(
      self,
      selector: #selector(appLaunched(_:)),
      name: NSWorkspace.didLaunchApplicationNotification,
      object: nil
    )
    center.addObserver(
      self,
      selector: #selector(appTerminated(_:)),
      name: NSWorkspace.didTerminateApplicationNotification,
      object: nil
    )
  }

  deinit {
    NSWorkspace.shared.notificationCenter.removeObserver(self)
    for pid in Array(observers.keys) {
      removeObserver(pid: pid)
    }
  }

  // MARK: - EventChannel (apps abertos / novas janelas)

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

    // App com regra recém-lançado: passa a observar suas janelas futuras.
    if watchedBundleIds.contains(bundleId) {
      addObserver(for: app)
    }
  }

  @objc private func appTerminated(_ notification: Notification) {
    guard
      let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey]
        as? NSRunningApplication
    else { return }
    removeObserver(pid: app.processIdentifier)
  }

  // MARK: - Observação de novas janelas (AXObserver)

  /// Garante um observer para cada app em execução com regra ativa e remove
  /// os que ficaram fora da lista.
  private func reconcileObservers() {
    guard AXIsProcessTrusted() else { return }

    var watchedPids = Set<pid_t>()
    for app in NSWorkspace.shared.runningApplications {
      guard
        app.activationPolicy == .regular,
        let bundleId = app.bundleIdentifier,
        watchedBundleIds.contains(bundleId)
      else { continue }
      watchedPids.insert(app.processIdentifier)
      addObserver(for: app)
    }

    for pid in observers.keys where !watchedPids.contains(pid) {
      removeObserver(pid: pid)
    }
  }

  private func addObserver(for app: NSRunningApplication) {
    let pid = app.processIdentifier
    guard observers[pid] == nil, AXIsProcessTrusted() else { return }

    var observer: AXObserver?
    guard
      AXObserverCreate(pid, axWindowCreatedCallback, &observer) == .success,
      let observer
    else { return }

    let axApp = AXUIElementCreateApplication(pid)
    let refcon = Unmanaged.passUnretained(self).toOpaque()
    guard
      AXObserverAddNotification(
        observer, axApp, kAXWindowCreatedNotification as CFString, refcon
      ) == .success
    else { return }

    CFRunLoopAddSource(
      CFRunLoopGetMain(),
      AXObserverGetRunLoopSource(observer),
      .defaultMode
    )
    observers[pid] = observer
  }

  private func removeObserver(pid: pid_t) {
    guard let observer = observers.removeValue(forKey: pid) else { return }
    CFRunLoopRemoveSource(
      CFRunLoopGetMain(),
      AXObserverGetRunLoopSource(observer),
      .defaultMode
    )
  }

  /// Chamado pelo callback do AXObserver quando o app observado cria uma
  /// janela. Emite o evento com o windowId para o rules engine posicioná-la.
  fileprivate func windowCreated(element: AXUIElement) {
    // Só janelas padrão — ignora sheets, diálogos e painéis. O título não é
    // filtrado: janelas recém-criadas podem ainda não tê-lo definido.
    guard subrole(of: element) == kAXStandardWindowSubrole as String else {
      return
    }

    // Diálogos de confirmação podem vir com subrole padrão — descarta
    // janelas modais e as de tamanho fixo (sem AXSize alterável).
    var modalRef: CFTypeRef?
    if AXUIElementCopyAttributeValue(
      element, kAXModalAttribute as CFString, &modalRef) == .success,
      (modalRef as? Bool) == true {
      return
    }
    var sizeSettable = DarwinBoolean(false)
    if AXUIElementIsAttributeSettable(
      element, kAXSizeAttribute as CFString, &sizeSettable) == .success,
      !sizeSettable.boolValue {
      return
    }

    var pid: pid_t = 0
    guard AXUIElementGetPid(element, &pid) == .success else { return }
    guard
      let app = NSRunningApplication(processIdentifier: pid),
      let bundleId = app.bundleIdentifier
    else { return }

    var windowId: CGWindowID = 0
    if _AXUIElementGetWindow(element, &windowId) == .success, windowId != 0 {
      emitWindowCreated(app: app, bundleId: bundleId, windowId: windowId)
      return
    }

    // A janela pode ainda não ter id resolvível logo após a criação.
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self] in
      var retryId: CGWindowID = 0
      guard
        _AXUIElementGetWindow(element, &retryId) == .success, retryId != 0
      else { return }
      self?.emitWindowCreated(app: app, bundleId: bundleId, windowId: retryId)
    }
  }

  private func emitWindowCreated(
    app: NSRunningApplication,
    bundleId: String,
    windowId: CGWindowID
  ) {
    eventSink?([
      "bundleId": bundleId,
      "appName": app.localizedName ?? bundleId,
      "windowId": Int(windowId),
      "pid": Int(app.processIdentifier),
    ])
  }

  private func subrole(of element: AXUIElement) -> String? {
    var value: CFTypeRef?
    guard
      AXUIElementCopyAttributeValue(
        element, kAXSubroleAttribute as CFString, &value
      ) == .success
    else { return nil }
    return value as? String
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

    case "setRuleApps":
      let bundleIds =
        (call.arguments as? [String: Any])?["bundleIds"] as? [String] ?? []
      watchedBundleIds = Set(bundleIds)
      reconcileObservers()
      result(nil)

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
