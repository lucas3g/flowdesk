import 'package:bloc_test/bloc_test.dart';
import 'package:flowdesk/core/errors/failures.dart';
import 'package:flowdesk/core/usecases/usecase.dart';
import 'package:flowdesk/features/monitors/domain/entities/monitor.dart';
import 'package:flowdesk/features/monitors/domain/usecases/get_monitors.dart';
import 'package:flowdesk/features/settings/domain/usecases/get_settings.dart';
import 'package:flowdesk/features/settings/domain/usecases/save_settings.dart';
import 'package:flowdesk/features/settings/presentation/cubits/settings_cubit.dart';
import 'package:flowdesk/features/windows/domain/entities/managed_window.dart';
import 'package:flowdesk/features/windows/domain/usecases/center_window.dart';
import 'package:flowdesk/features/windows/domain/usecases/focus_window.dart';
import 'package:flowdesk/features/windows/domain/usecases/get_windows.dart';
import 'package:flowdesk/features/windows/domain/usecases/maximize_window.dart';
import 'package:flowdesk/features/windows/presentation/cubits/windows_cubit.dart';
import 'package:flowdesk/features/windows/presentation/cubits/windows_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fakes.dart';

class _MockGetWindows extends Mock implements GetWindows {}

class _MockGetMonitors extends Mock implements GetMonitors {}

class _MockFocusWindow extends Mock implements FocusWindow {}

class _MockCenterWindow extends Mock implements CenterWindow {}

class _MockMaximizeWindow extends Mock implements MaximizeWindow {}

class _MockGetSettings extends Mock implements GetSettings {}

class _MockSaveSettings extends Mock implements SaveSettings {}

ManagedWindow _window(int id, {int monitorId = 1, String app = 'App'}) =>
    ManagedWindow(
      id: id,
      pid: id * 10,
      appName: app,
      bundleId: '',
      title: 'Janela $id',
      x: 0,
      y: 0,
      width: 800,
      height: 600,
      monitorId: monitorId,
      isFocused: false,
    );

Monitor _monitor(int id) => Monitor(
  id: id,
  name: 'Monitor $id',
  x: 0,
  y: 0,
  width: 1920,
  height: 1080,
  visibleWidth: 1920,
  visibleHeight: 1055,
  pixelWidth: 1920,
  pixelHeight: 1080,
  scale: 1,
  refreshRate: 60,
  isPrimary: id == 1,
  isBuiltIn: false,
);

void main() {
  late _MockGetWindows getWindows;
  late _MockGetMonitors getMonitors;
  late _MockFocusWindow focusWindow;
  late _MockCenterWindow centerWindow;
  late _MockMaximizeWindow maximizeWindow;
  late SettingsCubit settingsCubit;

  setUpAll(() {
    registerFallbackValue(const NoParams());
    registerFallbackValue(_window(0));
    registerFallbackValue(
      CenterParams(window: _window(0), monitor: _monitor(1)),
    );
    registerFallbackValue(
      MaximizeParams(window: _window(0), monitor: _monitor(1)),
    );
  });

  setUp(() {
    getWindows = _MockGetWindows();
    getMonitors = _MockGetMonitors();
    focusWindow = _MockFocusWindow();
    centerWindow = _MockCenterWindow();
    maximizeWindow = _MockMaximizeWindow();
    settingsCubit = SettingsCubit(
      _MockGetSettings(),
      _MockSaveSettings(),
      FakeApplySystemIntegration(),
    );

    when(() => getWindows(any())).thenAnswer(
      (_) async => right([_window(1), _window(2, monitorId: 2)]),
    );
    when(() => getMonitors(any())).thenAnswer(
      (_) async => right([_monitor(1), _monitor(2)]),
    );
  });

  tearDown(() => settingsCubit.close());

  WindowsCubit buildCubit() => WindowsCubit(
    getWindows,
    getMonitors,
    focusWindow,
    centerWindow,
    maximizeWindow,
    settingsCubit,
    MockUndoRedoCubit(),
  );

  blocTest<WindowsCubit, WindowsState>(
    'refresh carrega janelas e monitores',
    build: buildCubit,
    act: (cubit) => cubit.refresh(),
    expect: () => [
      isA<WindowsState>()
          .having((s) => s.status, 'status', WindowsStatus.ready)
          .having((s) => s.windows.length, 'windows', 2)
          .having((s) => s.monitors.length, 'monitors', 2),
    ],
  );

  blocTest<WindowsCubit, WindowsState>(
    'refresh com falha emite erro',
    setUp: () => when(() => getWindows(any())).thenAnswer(
      (_) async => left(const PlatformFailure('canal indisponível')),
    ),
    build: buildCubit,
    act: (cubit) => cubit.refresh(),
    expect: () => [
      isA<WindowsState>().having(
        (s) => s.status,
        'status',
        WindowsStatus.error,
      ),
    ],
  );

  test('filtro por monitor e busca', () {
    final state = WindowsState(
      status: WindowsStatus.ready,
      windows: [
        _window(1, app: 'Safari'),
        _window(2, monitorId: 2, app: 'VS Code'),
      ],
      monitors: [_monitor(1), _monitor(2)],
    );

    expect(state.filtered.length, 2);
    expect(state.countForMonitor(2), 1);

    final byMonitor = state.copyWith(selectedMonitorId: () => 2);
    expect(byMonitor.filtered.single.appName, 'VS Code');

    final byQuery = state.copyWith(query: 'safari');
    expect(byQuery.filtered.single.appName, 'Safari');
  });

  blocTest<WindowsCubit, WindowsState>(
    'maximize usa a margem das preferências e recarrega',
    setUp: () => when(
      () => maximizeWindow(any()),
    ).thenAnswer((_) async => right(true)),
    build: buildCubit,
    seed: () => WindowsState(
      status: WindowsStatus.ready,
      windows: [_window(1)],
      monitors: [_monitor(1)],
    ),
    act: (cubit) => cubit.maximize(_window(1)),
    verify: (_) {
      final captured =
          verify(() => maximizeWindow(captureAny())).captured.single
              as MaximizeParams;
      expect(captured.margin, 8);
      verify(() => getWindows(any())).called(1);
    },
  );

  blocTest<WindowsCubit, WindowsState>(
    'focus chama o use case e recarrega',
    setUp: () =>
        when(() => focusWindow(any())).thenAnswer((_) async => right(true)),
    build: buildCubit,
    seed: () => WindowsState(
      status: WindowsStatus.ready,
      windows: [_window(1)],
      monitors: [_monitor(1)],
    ),
    act: (cubit) => cubit.focus(_window(1)),
    verify: (_) {
      verify(() => focusWindow(any())).called(1);
      verify(() => getWindows(any())).called(1);
    },
  );
}
