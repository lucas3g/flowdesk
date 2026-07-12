import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
  // Precisa ser false: além do fechamento real, o AppKit consulta este método
  // quando a última janela é apenas escondida (orderOut) — com true, o app
  // encerraria ao fechar no X mesmo com o preventClose interceptando.
  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return false
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }

  // O X vermelho apenas esconde a janela (preventClose no lado Dart); ao
  // clicar no ícone da Dock, a janela escondida volta a aparecer.
  override func applicationShouldHandleReopen(
    _ sender: NSApplication, hasVisibleWindows flag: Bool
  ) -> Bool {
    if !flag {
      mainFlutterWindow?.makeKeyAndOrderFront(self)
    }
    return true
  }
}
