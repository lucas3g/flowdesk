import 'package:flowdesk/features/shortcuts/domain/entities/hotkey_combo.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HotkeyCombo.tryParse', () {
    test('converte ⌥1 para keycode/modifiers do Carbon', () {
      final combo = HotkeyCombo.tryParse('⌥1')!;

      expect(combo.keyCode, 18); // ANSI_1
      expect(combo.modifiers, 0x0800); // optionKey
      expect(combo.display, '⌥1');
    });

    test('combina múltiplos modificadores', () {
      final combo = HotkeyCombo.tryParse('⌃⌥5')!;

      expect(combo.keyCode, 23); // ANSI_5
      expect(combo.modifiers, 0x1000 | 0x0800); // control + option

      final cmdCombo = HotkeyCombo.tryParse('⌥⌘9')!;
      expect(cmdCombo.keyCode, 25); // ANSI_9
      expect(cmdCombo.modifiers, 0x0800 | 0x0100); // option + cmd
    });

    test('rejeita entradas inválidas', () {
      expect(HotkeyCombo.tryParse(null), isNull);
      expect(HotkeyCombo.tryParse(''), isNull);
      expect(HotkeyCombo.tryParse('1'), isNull); // sem modificador
      expect(HotkeyCombo.tryParse('⌥'), isNull); // sem tecla
      expect(HotkeyCombo.tryParse('⌥X'), isNull); // tecla não suportada
      expect(HotkeyCombo.tryParse('⌥12'), isNull); // duas teclas
    });

    test('combos de ciclo de região usam setas com ⌘⌥ e Ctrl+Win', () {
      const prev = HotkeyCombo.cycleRegionPrev;
      expect(prev.keyCode, 123); // seta esquerda
      expect(prev.modifiers, 0x0100 | 0x0800); // cmd + option (macOS)
      expect(prev.key, 'left');
      expect(prev.hasControl, isTrue); // Ctrl no Windows
      expect(prev.hasWin, isTrue); // Win no Windows
      expect(prev.hasOption, isFalse);

      const next = HotkeyCombo.cycleRegionNext;
      expect(next.keyCode, 124); // seta direita
      expect(next.key, 'right');
      expect(next.hasWin, isTrue);
    });

    test('todas as opções oferecidas são parseáveis', () {
      for (final option in [
        ...HotkeyCombo.layoutOptions(),
        ...HotkeyCombo.workspaceOptions(),
      ]) {
        expect(HotkeyCombo.tryParse(option), isNotNull, reason: option);
      }
    });
  });
}
