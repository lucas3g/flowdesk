import 'package:bloc_test/bloc_test.dart';
import 'package:flowdesk/core/services/window_snap_service.dart';
import 'package:flowdesk/features/layouts/domain/entities/layout.dart';
import 'package:flowdesk/features/layouts/domain/usecases/apply_layout.dart';
import 'package:flowdesk/features/monitors/domain/entities/monitor.dart';
import 'package:flowdesk/features/monitors/presentation/cubits/monitors_cubit.dart';
import 'package:flowdesk/features/monitors/presentation/cubits/monitors_state.dart';
import 'package:flowdesk/features/settings/domain/entities/app_settings.dart';
import 'package:flowdesk/features/settings/presentation/cubits/settings_cubit.dart';
import 'package:flowdesk/features/settings/presentation/cubits/settings_state.dart';
import 'package:flowdesk/features/windows/domain/entities/managed_window.dart';
import 'package:flowdesk/features/windows/domain/repositories/windows_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class _MockSettingsCubit extends MockCubit<SettingsState>
    implements SettingsCubit {}

class _MockMonitorsCubit extends MockCubit<MonitorsState>
    implements MonitorsCubit {}

class _MockWindowsRepository extends Mock implements WindowsRepository {}

// Área útil 2000×1000 a partir da origem — facilita conferir os frames.
const _monitor = Monitor(
  id: 1,
  name: 'Principal',
  x: 0,
  y: 0,
  width: 2000,
  height: 1200,
  visibleX: 0,
  visibleY: 0,
  visibleWidth: 2000,
  visibleHeight: 1000,
  pixelWidth: 4000,
  pixelHeight: 2400,
  scale: 2,
  refreshRate: 60,
  isPrimary: true,
  isBuiltIn: false,
);

ManagedWindow _window({
  required double x,
  required double y,
  required double width,
  required double height,
  bool isFocused = true,
}) => ManagedWindow(
  id: 10,
  pid: 100,
  appName: 'App',
  bundleId: 'com.app',
  title: 'Janela',
  x: x,
  y: y,
  width: width,
  height: height,
  monitorId: 1,
  isFocused: isFocused,
);

/// Frame esperado de uma região sintética (gap/margem 0).
RegionFrame _frame(double x, double y, double w, double h) => regionFrameOnMonitor(
  LayoutRegion(name: 'r', x: x, y: y, width: w, height: h),
  _monitor,
);

void main() {
  late _MockSettingsCubit settingsCubit;
  late _MockMonitorsCubit monitorsCubit;
  late _MockWindowsRepository windowsRepository;

  // Posições de referência.
  final leftHalf = _frame(0, 0, 50, 100);
  final topLeft = _frame(0, 0, 50, 50);
  final bottomLeft = _frame(0, 50, 50, 50);
  final rightHalf = _frame(50, 0, 50, 100);
  final maximize = _frame(0, 0, 100, 100);
  final center = _frame(20, 15, 60, 70);

  setUpAll(() {
    registerFallbackValue(_window(x: 0, y: 0, width: 1, height: 1));
  });

  setUp(() {
    settingsCubit = _MockSettingsCubit();
    monitorsCubit = _MockMonitorsCubit();
    windowsRepository = _MockWindowsRepository();

    when(() => monitorsCubit.state).thenReturn(
      const MonitorsState(status: MonitorsStatus.ready, monitors: [_monitor]),
    );
    when(() => settingsCubit.state).thenReturn(
      const SettingsState(
        status: SettingsStatus.ready,
        settings: AppSettings(
          keyboardSnap: true,
          windowGap: 0,
          screenMargin: 0,
        ),
      ),
    );
    when(
      () => windowsRepository.setWindowFrame(
        any(),
        x: any(named: 'x'),
        y: any(named: 'y'),
        width: any(named: 'width'),
        height: any(named: 'height'),
        settle: any(named: 'settle'),
      ),
    ).thenAnswer((_) async => right(true));
  });

  WindowSnapService buildService() => WindowSnapService(
    settingsCubit,
    monitorsCubit,
    windowsRepository,
  );

  void stubFocused(ManagedWindow window) {
    when(
      () => windowsRepository.getWindows(),
    ).thenAnswer((_) async => right([window]));
  }

  void expectMovedTo(RegionFrame frame) {
    verify(
      () => windowsRepository.setWindowFrame(
        any(),
        x: frame.x,
        y: frame.y,
        width: frame.width,
        height: frame.height,
        settle: false,
      ),
    ).called(1);
  }

  void verifyNoMove() {
    verifyNever(
      () => windowsRepository.setWindowFrame(
        any(),
        x: any(named: 'x'),
        y: any(named: 'y'),
        width: any(named: 'width'),
        height: any(named: 'height'),
      ),
    );
  }

  test('esquerda encaixa a janela na metade esquerda', () async {
    stubFocused(_window(x: 300, y: 200, width: 500, height: 400));

    await buildService().snap(SnapDirection.left);

    expectMovedTo(leftHalf);
  });

  test('direita encaixa a janela na metade direita', () async {
    stubFocused(_window(x: 300, y: 200, width: 500, height: 400));

    await buildService().snap(SnapDirection.right);

    expectMovedTo(rightHalf);
  });

  test('cima maximiza a janela na área útil', () async {
    stubFocused(_window(x: 300, y: 200, width: 500, height: 400));

    await buildService().snap(SnapDirection.up);

    expectMovedTo(maximize);
  });

  test('baixo centraliza a janela', () async {
    stubFocused(_window(x: 0, y: 0, width: 2000, height: 1000));

    await buildService().snap(SnapDirection.down);

    expectMovedTo(center);
  });

  test('repetir esquerda avança metade → quadrante superior', () async {
    stubFocused(
      _window(
        x: leftHalf.x,
        y: leftHalf.y,
        width: leftHalf.width,
        height: leftHalf.height,
      ),
    );

    await buildService().snap(SnapDirection.left);

    expectMovedTo(topLeft);
  });

  test('repetir esquerda avança quadrante superior → inferior', () async {
    stubFocused(
      _window(
        x: topLeft.x,
        y: topLeft.y,
        width: topLeft.width,
        height: topLeft.height,
      ),
    );

    await buildService().snap(SnapDirection.left);

    expectMovedTo(bottomLeft);
  });

  test('repetir esquerda dá a volta: inferior → metade', () async {
    stubFocused(
      _window(
        x: bottomLeft.x,
        y: bottomLeft.y,
        width: bottomLeft.width,
        height: bottomLeft.height,
      ),
    );

    await buildService().snap(SnapDirection.left);

    expectMovedTo(leftHalf);
  });

  test('não age quando a preferência está desligada', () async {
    when(() => settingsCubit.state).thenReturn(
      const SettingsState(
        status: SettingsStatus.ready,
        settings: AppSettings(windowGap: 0, screenMargin: 0),
      ),
    );
    stubFocused(_window(x: 300, y: 200, width: 500, height: 400));

    await buildService().snap(SnapDirection.left);

    verifyNoMove();
  });

  test('sem janela focada não move nada', () async {
    stubFocused(
      _window(x: 0, y: 0, width: 400, height: 400, isFocused: false),
    );

    await buildService().snap(SnapDirection.left);

    verifyNoMove();
  });
}
