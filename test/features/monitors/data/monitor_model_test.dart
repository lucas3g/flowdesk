import 'package:flowdesk/features/monitors/data/models/monitor_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('fromMap converte o payload completo do canal', () {
    final monitor = MonitorModel.fromMap(const {
      'id': 42,
      'name': 'LG UltraWide',
      'x': 0.0,
      'y': 0.0,
      'width': 3440.0,
      'height': 1440.0,
      'pixelWidth': 5120,
      'pixelHeight': 2160,
      'scale': 1.5,
      'refreshRate': 75.0,
      'isPrimary': true,
      'isBuiltIn': false,
    });

    expect(monitor.id, 42);
    expect(monitor.name, 'LG UltraWide');
    expect(monitor.resolutionLabel, '5120 × 2160');
    expect(monitor.scale, 1.5);
    expect(monitor.refreshRate, 75);
    expect(monitor.isPrimary, isTrue);
    expect(monitor.isBuiltIn, isFalse);
    expect(monitor.isPortrait, isFalse);
  });

  test('fromMap usa padrões seguros para campos ausentes', () {
    final monitor = MonitorModel.fromMap(const {});

    expect(monitor.id, 0);
    expect(monitor.name, 'Monitor');
    expect(monitor.scale, 1);
    expect(monitor.refreshRate, 0);
    expect(monitor.isPrimary, isFalse);
  });

  test('listFromChannel converte lista crua com chaves Object?', () {
    final payload = <Object?>[
      <Object?, Object?>{'id': 1, 'name': 'A', 'isPrimary': true},
      <Object?, Object?>{'id': 2, 'name': 'B'},
      'lixo que deve ser ignorado',
    ];

    final monitors = MonitorModel.listFromChannel(payload);

    expect(monitors.length, 2);
    expect(monitors.first.id, 1);
    expect(monitors.first.isPrimary, isTrue);
    expect(monitors.last.name, 'B');
  });

  test('listFromChannel retorna vazio para payload inválido', () {
    expect(MonitorModel.listFromChannel(null), isEmpty);
    expect(MonitorModel.listFromChannel('não é lista'), isEmpty);
  });
}
