import Cocoa
import FlutterMacOS

/// Ícone e menu do FlowDesk na barra de menus do macOS, além da política
/// de exibição no Dock. As ações do menu são enviadas ao Flutter pelo
/// EventChannel `flowdesk/app/events`.
final class StatusBarManager: NSObject, FlutterStreamHandler {
  private var statusItem: NSStatusItem?
  private var eventSink: FlutterEventSink?

  /// Conteúdo dinâmico do menu (id, nome, atalho/emoji).
  private var layouts: [[String: Any]] = []
  private var workspaces: [[String: Any]] = []

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let args = call.arguments as? [String: Any]

    switch call.method {
    case "setStatusBarVisible":
      let visible = args?["visible"] as? Bool ?? true
      visible ? show() : hide()
      result(nil)

    case "setStatusBarMenu":
      layouts = args?["layouts"] as? [[String: Any]] ?? []
      workspaces = args?["workspaces"] as? [[String: Any]] ?? []
      rebuildMenu()
      result(nil)

    case "setDockVisible":
      let visible = args?["visible"] as? Bool ?? true
      NSApp.setActivationPolicy(visible ? .regular : .accessory)
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

  // MARK: - Status item

  private func show() {
    guard statusItem == nil else { return }
    let item = NSStatusBar.system.statusItem(
      withLength: NSStatusItem.squareLength
    )
    item.button?.image = NSImage(
      systemSymbolName: "square.grid.2x2",
      accessibilityDescription: "FlowDesk"
    )
    statusItem = item
    rebuildMenu()
  }

  private func hide() {
    if let item = statusItem {
      NSStatusBar.system.removeStatusItem(item)
    }
    statusItem = nil
  }

  private func rebuildMenu() {
    guard let statusItem else { return }

    let menu = NSMenu()

    let openItem = NSMenuItem(
      title: "Abrir o FlowDesk",
      action: #selector(openApp),
      keyEquivalent: ""
    )
    openItem.target = self
    menu.addItem(openItem)
    menu.addItem(.separator())

    if !layouts.isEmpty {
      let layoutsItem = NSMenuItem(title: "Layouts", action: nil, keyEquivalent: "")
      let submenu = NSMenu()
      for layout in layouts {
        guard let id = layout["id"] as? Int,
          let name = layout["name"] as? String
        else { continue }
        let item = NSMenuItem(
          title: name,
          action: #selector(applyLayout(_:)),
          keyEquivalent: ""
        )
        item.target = self
        item.tag = id
        if let shortcut = layout["shortcut"] as? String, !shortcut.isEmpty {
          item.toolTip = shortcut
        }
        submenu.addItem(item)
      }
      menu.setSubmenu(submenu, for: layoutsItem)
      menu.addItem(layoutsItem)
    }

    if !workspaces.isEmpty {
      let workspacesItem = NSMenuItem(
        title: "Workspaces",
        action: nil,
        keyEquivalent: ""
      )
      let submenu = NSMenu()
      for workspace in workspaces {
        guard let id = workspace["id"] as? Int,
          let name = workspace["name"] as? String
        else { continue }
        let emoji = workspace["emoji"] as? String ?? ""
        let item = NSMenuItem(
          title: emoji.isEmpty ? name : "\(emoji) \(name)",
          action: #selector(applyWorkspace(_:)),
          keyEquivalent: ""
        )
        item.target = self
        item.tag = id
        submenu.addItem(item)
      }
      menu.setSubmenu(submenu, for: workspacesItem)
      menu.addItem(workspacesItem)
    }

    menu.addItem(.separator())
    let preferencesItem = NSMenuItem(
      title: "Preferências…",
      action: #selector(openPreferences),
      keyEquivalent: ","
    )
    preferencesItem.target = self
    menu.addItem(preferencesItem)

    let quitItem = NSMenuItem(
      title: "Sair do FlowDesk",
      action: #selector(NSApplication.terminate(_:)),
      keyEquivalent: "q"
    )
    menu.addItem(quitItem)

    statusItem.menu = menu
  }

  // MARK: - Ações do menu

  @objc private func openApp() {
    activateWindow()
    eventSink?(["type": "openApp"])
  }

  @objc private func openPreferences() {
    activateWindow()
    eventSink?(["type": "openPreferences"])
  }

  @objc private func applyLayout(_ sender: NSMenuItem) {
    eventSink?(["type": "applyLayout", "id": sender.tag])
  }

  @objc private func applyWorkspace(_ sender: NSMenuItem) {
    eventSink?(["type": "applyWorkspace", "id": sender.tag])
  }

  private func activateWindow() {
    NSApp.activate(ignoringOtherApps: true)
    NSApp.windows.first?.makeKeyAndOrderFront(nil)
  }
}
