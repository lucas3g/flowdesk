import 'package:flowdesk/features/layouts/domain/entities/layout.dart';
import 'package:flowdesk/features/layouts/domain/usecases/apply_layout.dart';
import 'package:flowdesk/features/monitors/domain/entities/monitor.dart';
import 'package:flowdesk/features/windows/domain/entities/managed_window.dart';
import 'package:flowdesk/features/windows/domain/repositories/windows_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class _MockWindowsRepository extends Mock implements WindowsRepository {}

const _monitor = Monitor(
  id: 1,
  name: 'Principal',
  x: 0,
  y: 0,
  width: 2000,
  height: 1200,
  visibleX: 0,
  visibleY: 25,
  visibleWidth: 2000,
  visibleHeight: 1000,
  pixelWidth: 4000,
  pixelHeight: 2400,
  scale: 2,
  refreshRate: 60,
  isPrimary: true,
  isBuiltIn: false,
);

ManagedWindow _window(
  int id, {
  String bundleId = '',
  double width = 500,
  String title = '',
}) =>
    ManagedWindow(
      id: id,
      pid: id,
      appName: 'App $id',
      bundleId: bundleId,
      title: title,
      x: 0,
      y: 0,
      width: width,
      height: 500,
      monitorId: 1,
      isFocused: false,
    );

void main() {
  group('regionFrameOnMonitor', () {
    test('sem gap/margem ocupa a fração exata da área útil', () {
      const region = LayoutRegion(name: 'Meia', x: 50, y: 0, width: 50, height: 100);

      final frame = regionFrameOnMonitor(region, _monitor);

      expect(frame.x, 1000);
      expect(frame.y, 25);
      expect(frame.width, 1000);
      expect(frame.height, 1000);
    });

    test('aplica margem externa e metade do gap em cada lado', () {
      const region = LayoutRegion(name: 'Cheia', x: 0, y: 0, width: 100, height: 100);

      final frame = regionFrameOnMonitor(region, _monitor, gap: 8, margin: 10);

      expect(frame.x, 14); // 0 + margem 10 + gap/2
      expect(frame.y, 39); // 25 + 10 + 4
      expect(frame.width, 1972); // 2000 - 2*10 - 8
      expect(frame.height, 972); // 1000 - 2*10 - 8
    });
  });

  group('ApplyLayout', () {
    late _MockWindowsRepository repository;

    setUpAll(() => registerFallbackValue(_window(0)));

    setUp(() {
      repository = _MockWindowsRepository();
      when(
        () => repository.setWindowFrame(
          any(),
          x: any(named: 'x'),
          y: any(named: 'y'),
          width: any(named: 'width'),
          height: any(named: 'height'),
        ),
      ).thenAnswer((_) async => right(true));
    });

    test('posiciona uma janela por região, respeitando o sortOrder', () async {
      const layout = Layout(
        id: 1,
        name: 'Metades',
        regions: [
          LayoutRegion(name: 'Direita', x: 50, y: 0, width: 50, height: 100, sortOrder: 1),
          LayoutRegion(name: 'Esquerda', x: 0, y: 0, width: 50, height: 100, sortOrder: 0),
        ],
      );
      final windows = [_window(1), _window(2), _window(3)];

      final result = await ApplyLayout(repository)(
        ApplyLayoutParams(layout: layout, monitor: _monitor, windows: windows),
      );

      // Apenas 2 regiões → 2 janelas posicionadas; a primeira janela vai
      // para a região de menor sortOrder (Esquerda, x=0).
      expect(result.getOrElse((_) => 0), 2);
      verify(
        () => repository.setWindowFrame(
          windows[0],
          x: 0,
          y: 25,
          width: 1000,
          height: 1000,
        ),
      ).called(1);
      verify(
        () => repository.setWindowFrame(
          windows[1],
          x: 1000,
          y: 25,
          width: 1000,
          height: 1000,
        ),
      ).called(1);
      verifyNever(
        () => repository.setWindowFrame(
          windows[2],
          x: any(named: 'x'),
          y: any(named: 'y'),
          width: any(named: 'width'),
          height: any(named: 'height'),
        ),
      );
    });

    test(
      'região com título de janela escolhe a instância correta do app',
      () async {
        const layout = Layout(
          id: 1,
          name: 'Dev',
          regions: [
            LayoutRegion(
              name: 'Editor',
              x: 0,
              y: 0,
              width: 100,
              height: 100,
              appBundleId: 'com.vscode',
              appName: 'VS Code',
              appWindowTitle: 'flowdesk',
            ),
          ],
        );
        // A instância desejada NÃO é a maior janela do app.
        final windows = [
          _window(1, bundleId: 'com.vscode', width: 1200, title: 'outro-projeto'),
          _window(2, bundleId: 'com.vscode', width: 300, title: 'flowdesk'),
        ];

        final result = await ApplyLayout(repository)(
          ApplyLayoutParams(
            layout: layout,
            monitor: _monitor,
            windows: windows,
          ),
        );

        expect(result.getOrElse((_) => 0), 1);
        verify(
          () => repository.setWindowFrame(
            windows[1],
            x: 0,
            y: 25,
            width: 2000,
            height: 1000,
          ),
        ).called(1);
      },
    );

    test('região com app associado recebe a janela daquele app', () async {
      const layout = Layout(
        id: 1,
        name: 'Dev',
        regions: [
          LayoutRegion(
            name: 'Editor',
            x: 0,
            y: 0,
            width: 50,
            height: 100,
            appBundleId: 'com.vscode',
            appName: 'VS Code',
          ),
          LayoutRegion(
            name: 'Livre',
            x: 50,
            y: 0,
            width: 50,
            height: 100,
            sortOrder: 1,
          ),
        ],
      );
      // O VS Code não é a primeira janela da lista — e tem duas janelas
      // (a maior é a principal).
      final windows = [
        _window(1, bundleId: 'com.safari'),
        _window(2, bundleId: 'com.vscode', width: 300),
        _window(3, bundleId: 'com.vscode', width: 1200),
      ];

      final result = await ApplyLayout(repository)(
        ApplyLayoutParams(layout: layout, monitor: _monitor, windows: windows),
      );

      expect(result.getOrElse((_) => 0), 2);
      // Janela principal do VS Code na região 'Editor' (esquerda).
      verify(
        () => repository.setWindowFrame(
          windows[2],
          x: 0,
          y: 25,
          width: 1000,
          height: 1000,
        ),
      ).called(1);
      // Primeira janela restante (Safari) na região livre (direita).
      verify(
        () => repository.setWindowFrame(
          windows[0],
          x: 1000,
          y: 25,
          width: 1000,
          height: 1000,
        ),
      ).called(1);
    });

    test('app associado fechado libera a região para a ordem normal', () async {
      const layout = Layout(
        id: 1,
        name: 'Dev',
        regions: [
          LayoutRegion(
            name: 'Editor',
            x: 0,
            y: 0,
            width: 100,
            height: 100,
            appBundleId: 'com.fechado',
            appName: 'Fechado',
          ),
        ],
      );

      final result = await ApplyLayout(repository)(
        ApplyLayoutParams(
          layout: layout,
          monitor: _monitor,
          windows: [_window(1, bundleId: 'com.safari')],
        ),
      );

      // A região é preenchida pela janela disponível.
      expect(result.getOrElse((_) => 0), 1);
    });
  });
}
