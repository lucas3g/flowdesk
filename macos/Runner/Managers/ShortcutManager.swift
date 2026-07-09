import Carbon
import FlutterMacOS

/// Registra hotkeys globais via Carbon (RegisterEventHotKey) e notifica o
/// Flutter pelo EventChannel quando um atalho é acionado.
final class ShortcutManager: NSObject, FlutterStreamHandler {
  private var eventSink: FlutterEventSink?
  private var hotKeyRefs: [EventHotKeyRef] = []
  private var eventHandlerRef: EventHandlerRef?

  /// 'FLDK' — assinatura dos hotkeys do FlowDesk.
  private static let signature: OSType = 0x464C_444B

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "registerShortcuts":
      guard let args = call.arguments as? [String: Any],
        let shortcuts = args["shortcuts"] as? [[String: Any]]
      else {
        result(
          FlutterError(
            code: "invalid_arguments",
            message: "Lista de atalhos ausente",
            details: nil
          )
        )
        return
      }
      unregisterAll()
      installHandlerIfNeeded()
      for shortcut in shortcuts {
        guard let id = shortcut["id"] as? Int,
          let keyCode = shortcut["keyCode"] as? Int,
          let modifiers = shortcut["modifiers"] as? Int
        else { continue }
        register(id: id, keyCode: keyCode, modifiers: modifiers)
      }
      result(true)

    case "unregisterAll":
      unregisterAll()
      result(nil)

    default:
      result(FlutterMethodNotImplemented)
    }
  }

  // MARK: - EventChannel

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

  fileprivate func emit(id: UInt32) {
    eventSink?(Int(id))
  }

  // MARK: - Carbon

  private func installHandlerIfNeeded() {
    guard eventHandlerRef == nil else { return }

    var eventType = EventTypeSpec(
      eventClass: OSType(kEventClassKeyboard),
      eventKind: UInt32(kEventHotKeyPressed)
    )

    InstallEventHandler(
      GetApplicationEventTarget(),
      { _, event, userData -> OSStatus in
        guard let event, let userData else { return noErr }
        var hotKeyID = EventHotKeyID()
        GetEventParameter(
          event,
          EventParamName(kEventParamDirectObject),
          EventParamType(typeEventHotKeyID),
          nil,
          MemoryLayout<EventHotKeyID>.size,
          nil,
          &hotKeyID
        )
        let manager = Unmanaged<ShortcutManager>
          .fromOpaque(userData)
          .takeUnretainedValue()
        manager.emit(id: hotKeyID.id)
        return noErr
      },
      1,
      &eventType,
      Unmanaged.passUnretained(self).toOpaque(),
      &eventHandlerRef
    )
  }

  private func register(id: Int, keyCode: Int, modifiers: Int) {
    var ref: EventHotKeyRef?
    let hotKeyID = EventHotKeyID(
      signature: ShortcutManager.signature,
      id: UInt32(id)
    )
    let status = RegisterEventHotKey(
      UInt32(keyCode),
      UInt32(modifiers),
      hotKeyID,
      GetApplicationEventTarget(),
      0,
      &ref
    )
    if status == noErr, let ref {
      hotKeyRefs.append(ref)
    }
  }

  private func unregisterAll() {
    for ref in hotKeyRefs {
      UnregisterEventHotKey(ref)
    }
    hotKeyRefs.removeAll()
  }
}
