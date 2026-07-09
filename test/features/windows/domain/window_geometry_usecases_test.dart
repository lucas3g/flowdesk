import 'package:flowdesk/features/monitors/domain/entities/monitor.dart';
import 'package:flowdesk/features/windows/domain/entities/managed_window.dart';
import 'package:flowdesk/features/windows/domain/repositories/windows_repository.dart';
import 'package:flowdesk/features/windows/domain/usecases/center_window.dart';
import 'package:flowdesk/features/windows/domain/usecases/maximize_window.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class _MockRepository extends Mock implements WindowsRepository {}

const _window = ManagedWindow(
  id: 1,
  pid: 100,
  appName: 'App',
  bundleId: '',
  title: '',
  x: 0,
  y: 0,
  width: 800,
  height: 600,
  monitorId: 1,
  isFocused: false,
);

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
  visibleHeight: 1100,
  pixelWidth: 4000,
  pixelHeight: 2400,
  scale: 2,
  refreshRate: 60,
  isPrimary: true,
  isBuiltIn: false,
);

void main() {
  late _MockRepository repository;

  setUpAll(() => registerFallbackValue(_window));

  setUp(() {
    repository = _MockRepository();
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

  test('MaximizeWindow ocupa a área útil respeitando a margem', () async {
    await MaximizeWindow(repository)(
      const MaximizeParams(window: _window, monitor: _monitor, margin: 8),
    );

    verify(
      () => repository.setWindowFrame(
        _window,
        x: 8,
        y: 33,
        width: 1984,
        height: 1084,
      ),
    ).called(1);
  });

  test('CenterWindow centraliza a fração configurada da área útil', () async {
    await CenterWindow(repository)(
      const CenterParams(
        window: _window,
        monitor: _monitor,
        widthFraction: 0.5,
        heightFraction: 0.5,
      ),
    );

    verify(
      () => repository.setWindowFrame(
        _window,
        x: 500,
        y: 25 + (1100 - 550) / 2,
        width: 1000,
        height: 550,
      ),
    ).called(1);
  });
}
