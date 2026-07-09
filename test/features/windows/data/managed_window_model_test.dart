import 'dart:typed_data';

import 'package:flowdesk/features/windows/data/models/managed_window_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('fromMap converte o payload completo', () {
    final icon = Uint8List.fromList([1, 2, 3]);
    final window = ManagedWindowModel.fromMap({
      'id': 101,
      'pid': 500,
      'appName': 'VS Code',
      'bundleId': 'com.microsoft.VSCode',
      'title': 'editor.dart — flowdesk',
      'x': 10.0,
      'y': 20.0,
      'width': 2560.0,
      'height': 1440.0,
      'monitorId': 7,
      'isFocused': true,
      'icon': icon,
    });

    expect(window.id, 101);
    expect(window.appName, 'VS Code');
    expect(window.displayTitle, 'editor.dart — flowdesk');
    expect(window.sizeLabel, '2560 × 1440');
    expect(window.monitorId, 7);
    expect(window.isFocused, isTrue);
    expect(window.icon, icon);
  });

  test('título vazio usa o nome do app e ícone vazio vira null', () {
    final window = ManagedWindowModel.fromMap({
      'appName': 'Safari',
      'title': '',
      'icon': Uint8List(0),
    });

    expect(window.displayTitle, 'Safari');
    expect(window.icon, isNull);
  });

  test('listFromChannel ignora entradas inválidas', () {
    final windows = ManagedWindowModel.listFromChannel([
      <Object?, Object?>{'id': 1, 'appName': 'A'},
      'inválido',
      <Object?, Object?>{'id': 2, 'appName': 'B'},
    ]);

    expect(windows.length, 2);
    expect(ManagedWindowModel.listFromChannel(null), isEmpty);
  });
}
