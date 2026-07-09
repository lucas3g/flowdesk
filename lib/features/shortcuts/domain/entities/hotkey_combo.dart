import 'package:equatable/equatable.dart';

/// Combinação de teclas global, exibida com símbolos do macOS (ex.: `⌃⌥1`)
/// e convertida para os códigos usados pelo Carbon (RegisterEventHotKey).
class HotkeyCombo extends Equatable {
  const HotkeyCombo._(
    this.display,
    this.keyCode,
    this.modifiers,
    this.key,
    this.hasCmd,
    this.hasShift,
    this.hasOption,
    this.hasControl,
  );

  final String display;

  /// Virtual key code (layout ANSI) — usado pelo Carbon no macOS.
  final int keyCode;

  /// Máscara de modificadores do Carbon (macOS).
  final int modifiers;

  /// Representação neutra (o dígito e os modificadores lógicos), usada pelo
  /// lado nativo para converter aos códigos de cada plataforma (ex.: Win32).
  final String key;
  final bool hasCmd;
  final bool hasShift;
  final bool hasOption;
  final bool hasControl;

  // Modificadores do Carbon Event Manager.
  static const int _cmd = 0x0100;
  static const int _shift = 0x0200;
  static const int _option = 0x0800;
  static const int _control = 0x1000;

  static const Map<String, int> _modifierSymbols = {
    '⌘': _cmd,
    '⇧': _shift,
    '⌥': _option,
    '⌃': _control,
  };

  /// Key codes ANSI dos dígitos.
  static const Map<String, int> _digitKeyCodes = {
    '1': 18,
    '2': 19,
    '3': 20,
    '4': 21,
    '5': 23,
    '6': 22,
    '7': 26,
    '8': 28,
    '9': 25,
    '0': 29,
  };

  /// Converte uma string como `⌃⌥1` em combo; null quando inválida.
  static HotkeyCombo? tryParse(String? display) {
    if (display == null || display.isEmpty) return null;

    var modifiers = 0;
    String? key;

    for (final char in display.split('')) {
      final modifier = _modifierSymbols[char];
      if (modifier != null) {
        modifiers |= modifier;
        continue;
      }
      // Apenas uma tecla não modificadora é suportada.
      if (key != null) return null;
      key = char;
    }

    final keyCode = key != null ? _digitKeyCodes[key] : null;
    if (keyCode == null || modifiers == 0) return null;

    return HotkeyCombo._(
      display,
      keyCode,
      modifiers,
      key!,
      modifiers & _cmd != 0,
      modifiers & _shift != 0,
      modifiers & _option != 0,
      modifiers & _control != 0,
    );
  }

  /// Combos oferecidos para layouts (⌥n e ⌥⌘n).
  static List<String> layoutOptions() => [
    for (var i = 1; i <= 9; i++) '⌥$i',
    for (var i = 1; i <= 9; i++) '⌥⌘$i',
  ];

  /// Combos oferecidos para workspaces (⌃n).
  static List<String> workspaceOptions() => [
    for (var i = 1; i <= 9; i++) '⌃$i',
  ];

  @override
  List<Object?> get props => [display, keyCode, modifiers, key];
}
