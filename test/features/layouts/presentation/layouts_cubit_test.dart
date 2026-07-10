import 'package:bloc_test/bloc_test.dart';
import 'package:flowdesk/core/usecases/usecase.dart';
import 'package:flowdesk/features/layouts/domain/entities/layout.dart';
import 'package:flowdesk/features/layouts/domain/usecases/apply_layout.dart';
import 'package:flowdesk/features/layouts/domain/usecases/delete_layout.dart';
import 'package:flowdesk/features/layouts/domain/usecases/get_layouts.dart';
import 'package:flowdesk/features/layouts/domain/usecases/toggle_favorite_layout.dart';
import 'package:flowdesk/features/layouts/presentation/cubits/layouts_cubit.dart';
import 'package:flowdesk/features/layouts/presentation/cubits/layouts_state.dart';
import 'package:flowdesk/features/monitors/domain/entities/monitor.dart';
import 'package:flowdesk/features/monitors/presentation/cubits/monitors_cubit.dart';
import 'package:flowdesk/features/monitors/presentation/cubits/monitors_state.dart';
import 'package:flowdesk/features/settings/domain/entities/app_settings.dart';
import 'package:flowdesk/features/settings/domain/usecases/get_settings.dart';
import 'package:flowdesk/features/settings/domain/usecases/save_settings.dart';
import 'package:flowdesk/features/settings/presentation/cubits/settings_cubit.dart';
import 'package:flowdesk/features/windows/domain/entities/managed_window.dart';
import 'package:flowdesk/features/windows/domain/usecases/get_windows.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flowdesk/features/layouts/domain/usecases/save_layout.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fakes.dart';

class _MockGetLayouts extends Mock implements GetLayouts {}

class _MockToggleFavorite extends Mock implements ToggleFavoriteLayout {}

class _MockDeleteLayout extends Mock implements DeleteLayout {}

class _MockApplyLayout extends Mock implements ApplyLayout {}

class _MockSaveLayout extends Mock implements SaveLayout {}

class _MockGetWindows extends Mock implements GetWindows {}

class _MockMonitorsCubit extends MockCubit<MonitorsState>
    implements MonitorsCubit {}

class _MockGetSettings extends Mock implements GetSettings {}

class _MockSaveSettings extends Mock implements SaveSettings {}

const _monitor = Monitor(
  id: 1,
  name: 'Principal',
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
  isPrimary: true,
  isBuiltIn: false,
);

const _layout = Layout(
  id: 1,
  name: 'Metades',
  regions: [
    LayoutRegion(name: 'Esq.', x: 0, y: 0, width: 50, height: 100),
    LayoutRegion(name: 'Dir.', x: 50, y: 0, width: 50, height: 100),
  ],
);

ManagedWindow _window(
  int id, {
  int monitorId = 1,
  bool focused = false,
  String bundleId = '',
}) => ManagedWindow(
  id: id,
  pid: id,
  appName: 'App $id',
  bundleId: bundleId,
  title: '',
  x: 0,
  y: 0,
  width: 500,
  height: 400,
  monitorId: monitorId,
  isFocused: focused,
);

void main() {
  late _MockGetLayouts getLayouts;
  late _MockToggleFavorite toggleFavorite;
  late _MockDeleteLayout deleteLayout;
  late _MockApplyLayout applyLayout;
  late _MockGetWindows getWindows;
  late _MockMonitorsCubit monitorsCubit;
  late SettingsCubit settingsCubit;

  setUpAll(() {
    registerFallbackValue(const NoParams());
    registerFallbackValue(const AppSettings());
    registerFallbackValue(
      const ToggleFavoriteParams(layoutId: 0, isFavorite: false),
    );
    registerFallbackValue(
      const ApplyLayoutParams(layout: _layout, monitor: _monitor, windows: []),
    );
  });

  setUp(() {
    getLayouts = _MockGetLayouts();
    toggleFavorite = _MockToggleFavorite();
    deleteLayout = _MockDeleteLayout();
    applyLayout = _MockApplyLayout();
    getWindows = _MockGetWindows();

    monitorsCubit = _MockMonitorsCubit();
    when(() => monitorsCubit.state).thenReturn(
      const MonitorsState(status: MonitorsStatus.ready, monitors: [_monitor]),
    );
    when(() => monitorsCubit.refresh()).thenAnswer((_) async {});
    // O apply registra o último layout aplicado nas preferências.
    final saveSettings = _MockSaveSettings();
    when(() => saveSettings(any())).thenAnswer((_) async => right(unit));
    settingsCubit = SettingsCubit(
      _MockGetSettings(),
      saveSettings,
      FakeApplySystemIntegration(),
    );

    when(() => getLayouts(any())).thenAnswer((_) async => right([_layout]));
  });

  tearDown(() => settingsCubit.close());

  LayoutsCubit buildCubit() => LayoutsCubit(
    getLayouts,
    toggleFavorite,
    deleteLayout,
    applyLayout,
    _MockSaveLayout(),
    getWindows,
    monitorsCubit,
    settingsCubit,
    MockUndoRedoCubit(),
    FakeAddHistoryEntry(),
  );

  blocTest<LayoutsCubit, LayoutsState>(
    'load carrega os layouts',
    build: buildCubit,
    act: (cubit) => cubit.load(),
    expect: () => [
      isA<LayoutsState>()
          .having((s) => s.status, 'status', LayoutsStatus.ready)
          .having((s) => s.layouts.length, 'layouts', 1),
    ],
  );

  test('filtros e busca', () {
    const dev = Layout(id: 1, name: 'Código', category: LayoutCategory.dev);
    const foco = Layout(
      id: 2,
      name: 'Zen',
      category: LayoutCategory.foco,
      isFavorite: true,
    );
    const state = LayoutsState(
      status: LayoutsStatus.ready,
      layouts: [dev, foco],
    );

    expect(state.filtered.length, 2);
    expect(
      state.copyWith(filter: LayoutsFilter.dev).filtered.single.name,
      'Código',
    );
    expect(
      state.copyWith(filter: LayoutsFilter.favorites).filtered.single.name,
      'Zen',
    );
    expect(state.copyWith(query: 'zen').filtered.single.name, 'Zen');
    expect(state.favoritesCount, 1);
  });

  blocTest<LayoutsCubit, LayoutsState>(
    'apply usa o monitor da janela em foco e o gap/margem das preferências',
    setUp: () {
      when(() => getWindows(any())).thenAnswer(
        (_) async => right([
          _window(1, focused: true),
          _window(2),
          _window(3, monitorId: 99),
        ]),
      );
      when(() => applyLayout(any())).thenAnswer((_) async => right(2));
    },
    build: buildCubit,
    act: (cubit) => cubit.apply(_layout),
    expect: () => [
      isA<LayoutsState>().having(
        (s) => s.feedback,
        'feedback',
        contains('aplicado a 2 janelas'),
      ),
    ],
    verify: (_) {
      final params =
          verify(() => applyLayout(captureAny())).captured.single
              as ApplyLayoutParams;
      expect(params.monitor.id, 1);
      // Janela do monitor 99 fica de fora.
      expect(params.windows.length, 2);
      expect(params.gap, 8);
      expect(params.margin, 8);
    },
  );

  blocTest<LayoutsCubit, LayoutsState>(
    'apply traz janela de app associado que está em outro monitor',
    setUp: () {
      when(() => getWindows(any())).thenAnswer(
        (_) async => right([
          _window(1, focused: true, bundleId: 'com.safari'),
          // VS Code está no monitor 2, mas é o app associado a uma região.
          _window(2, monitorId: 2, bundleId: 'com.vscode'),
        ]),
      );
      when(() => applyLayout(any())).thenAnswer((_) async => right(2));
    },
    build: buildCubit,
    act: (cubit) => cubit.apply(
      const Layout(
        id: 9,
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
      ),
    ),
    verify: (_) {
      final params =
          verify(() => applyLayout(captureAny())).captured.single
              as ApplyLayoutParams;
      // Ambas entram: Safari (monitor alvo) e VS Code (monitor 2, associado).
      expect(params.windows.length, 2);
      expect(
        params.windows.any((w) => w.bundleId == 'com.vscode'),
        isTrue,
      );
    },
  );

  blocTest<LayoutsCubit, LayoutsState>(
    'apply sem janelas no monitor ativo gera feedback',
    setUp: () => when(() => getWindows(any())).thenAnswer(
      (_) async => right([_window(3, monitorId: 99)]),
    ),
    build: buildCubit,
    act: (cubit) => cubit.apply(_layout),
    expect: () => [
      isA<LayoutsState>().having(
        (s) => s.feedback,
        'feedback',
        'Nenhuma janela para posicionar.',
      ),
    ],
  );

  blocTest<LayoutsCubit, LayoutsState>(
    'toggleFavorite inverte o estado e recarrega',
    setUp: () => when(
      () => toggleFavorite(any()),
    ).thenAnswer((_) async => right(unit)),
    build: buildCubit,
    act: (cubit) => cubit.toggleFavorite(_layout),
    verify: (_) {
      final params =
          verify(() => toggleFavorite(captureAny())).captured.single
              as ToggleFavoriteParams;
      expect(params.isFavorite, isTrue);
      verify(() => getLayouts(any())).called(1);
    },
  );

  blocTest<LayoutsCubit, LayoutsState>(
    'delete ignora presets',
    build: buildCubit,
    act: (cubit) => cubit.delete(_layout.copyWith(isPreset: true)),
    verify: (_) => verifyNever(() => deleteLayout(any())),
  );
}
