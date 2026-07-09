import ApplicationServices

/// Encapsula a Accessibility API (AXIsProcessTrusted).
///
/// A confiança de acessibilidade é pré-requisito para mover e redimensionar
/// janelas de outros aplicativos via AXUIElement.
final class AccessibilityManager {
  func isTrusted() -> Bool {
    AXIsProcessTrusted()
  }

  /// Verifica a confiança exibindo o prompt do sistema quando ausente.
  @discardableResult
  func requestTrust() -> Bool {
    let options =
      [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
      as CFDictionary
    return AXIsProcessTrustedWithOptions(options)
  }
}
