import 'package:bloc_test/bloc_test.dart';
import 'package:flowdesk/core/services/snap_regions_service.dart';
import 'package:flowdesk/core/usecases/usecase.dart';
import 'package:flowdesk/features/layouts/domain/entities/layout.dart';
import 'package:flowdesk/features/layouts/domain/usecases/apply_layout.dart';
import 'package:flowdesk/features/layouts/domain/usecases/get_layouts.dart';
import 'package:flowdesk/features/layouts/presentation/cubits/applied_layouts_cubit.dart';
import 'package:flowdesk/features/monitors/domain/entities/monitor.dart';
import 'package:flowdesk/features/monitors/presentation/cubits/monitors_cubit.dart';
import 'package:flowdesk/features/monitors/presentation/cubits/monitors_state.dart';
import 'package:flowdesk/features/settings/domain/entities/app_settings.dart';
import 'package:flowdesk/features/settings/domain/repositories/system_integration_repository.dart';
import 'package:flowdesk/features/settings/presentation/cubits/settings_cubit.dart';
import 'package:flowdesk/features/settings/presentation/cubits/settings_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class _MockSettingsCubit extends MockCubit<SettingsState>
    implements SettingsCubit {}

class _MockMonitorsCubit extends MockCubit<MonitorsState>
    implements MonitorsCubit {}

class _MockAppliedLayoutsCubit extends MockCubit<Map<String, int>>
    implements AppliedLayoutsCubit {}

class _MockGetLayouts extends Mock implements GetLayouts {}

class _MockSystemIntegrationRepository extends Mock
    implements SystemIntegrationRepository {}

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

const _secondMonitor = Monitor(
  id: 2,
  name: 'Externo',
  x: 2000,
  y: 0,
  width: 1920,
  height: 1080,
  visibleX: 2000,
  visibleY: 0,
  visibleWidth: 1920,
  visibleHeight: 1080,
  pixelWidth: 1920,
  pixelHeight: 1080,
  scale: 1,
  refreshRate: 60,
  isPrimary: false,
  isBuiltIn: false,
);

const _layout = Layout(
  id: 7,
  name: 'Metades',
  regions: [
    LayoutRegion(name: 'Esq.', x: 0, y: 0, width: 50, height: 100),
    LayoutRegion(name: 'Dir.', x: 50, y: 0, width: 50, height: 100),
  ],
);

const _secondLayout = Layout(
  id: 8,
  name: 'Inteira',
  regions: [
    LayoutRegion(name: 'Tudo', x: 0, y: 0, width: 100, height: 100),
  ],
);

void main() {
  late _MockSettingsCubit settingsCubit;
  late _MockMonitorsCubit monitorsCubit;
  late _MockAppliedLayoutsCubit appliedLayoutsCubit;
  late _MockGetLayouts getLayouts;
  late _MockSystemIntegrationRepository systemIntegration;

  setUpAll(() => registerFallbackValue(const NoParams()));

  setUp(() {
    settingsCubit = _MockSettingsCubit();
    monitorsCubit = _MockMonitorsCubit();
    appliedLayoutsCubit = _MockAppliedLayoutsCubit();
    getLayouts = _MockGetLayouts();
    systemIntegration = _MockSystemIntegrationRepository();

    whenListen(
      monitorsCubit,
      const Stream<MonitorsState>.empty(),
      initialState: const MonitorsState(
        status: MonitorsStatus.ready,
        monitors: [_monitor],
      ),
    );
    when(
      () => getLayouts(any()),
    ).thenAnswer((_) async => right([_layout, _secondLayout]));
    when(
      () => systemIntegration.setLayoutSnapRegions(
        enabled: any(named: 'enabled'),
        regions: any(named: 'regions'),
      ),
    ).thenAnswer((_) async => right(unit));
  });

  SnapRegionsService buildService() => SnapRegionsService(
    settingsCubit,
    monitorsCubit,
    appliedLayoutsCubit,
    getLayouts,
    systemIntegration,
  );

  void stubSettings(AppSettings settings) {
    whenListen(
      settingsCubit,
      const Stream<SettingsState>.empty(),
      initialState: SettingsState(
        status: SettingsStatus.ready,
        settings: settings,
      ),
    );
  }

  void stubApplied(Map<String, int> applied) {
    whenListen(
      appliedLayoutsCubit,
      const Stream<Map<String, int>>.empty(),
      initialState: applied,
    );
  }

  test('preferência desativada envia enabled=false sem regiões', () async {
    stubSettings(const AppSettings(snapToLayoutRegions: false));
    stubApplied({monitorKey(_monitor): _layout.id});

    await buildService().start();

    verify(
      () => systemIntegration.setLayoutSnapRegions(enabled: false, regions: []),
    ).called(1);
  });

  test('sem layout aplicado envia enabled=false', () async {
    stubSettings(const AppSettings(snapToLayoutRegions: true));
    stubApplied(const {});

    await buildService().start();

    verify(
      () => systemIntegration.setLayoutSnapRegions(enabled: false, regions: []),
    ).called(1);
  });

  test('ativada envia os frames das regiões no monitor do apply', () async {
    stubSettings(const AppSettings(snapToLayoutRegions: true));
    stubApplied({monitorKey(_monitor): _layout.id});

    await buildService().start();

    final expected = [
      for (final region in _layout.regions)
        regionFrameOnMonitor(region, _monitor, gap: 8, margin: 8),
    ];
    verify(
      () => systemIntegration.setLayoutSnapRegions(
        enabled: true,
        regions: expected,
      ),
    ).called(1);
  });

  test('dois monitores enviam a união das zonas de cada layout', () async {
    whenListen(
      monitorsCubit,
      const Stream<MonitorsState>.empty(),
      initialState: const MonitorsState(
        status: MonitorsStatus.ready,
        monitors: [_monitor, _secondMonitor],
      ),
    );
    stubSettings(const AppSettings(snapToLayoutRegions: true));
    stubApplied({
      monitorKey(_monitor): _layout.id,
      monitorKey(_secondMonitor): _secondLayout.id,
    });

    await buildService().start();

    final expected = [
      for (final region in _layout.regions)
        regionFrameOnMonitor(region, _monitor, gap: 8, margin: 8),
      for (final region in _secondLayout.regions)
        regionFrameOnMonitor(region, _secondMonitor, gap: 8, margin: 8),
    ];
    verify(
      () => systemIntegration.setLayoutSnapRegions(
        enabled: true,
        regions: expected,
      ),
    ).called(1);
  });

  test('layout inexistente envia enabled=false', () async {
    stubSettings(const AppSettings(snapToLayoutRegions: true));
    stubApplied({monitorKey(_monitor): 99});

    await buildService().start();

    verify(
      () => systemIntegration.setLayoutSnapRegions(enabled: false, regions: []),
    ).called(1);
  });

  test('monitor do apply desconectado envia enabled=false', () async {
    stubSettings(const AppSettings(snapToLayoutRegions: true));
    stubApplied({monitorKey(_secondMonitor): _layout.id});

    await buildService().start();

    verify(
      () => systemIntegration.setLayoutSnapRegions(enabled: false, regions: []),
    ).called(1);
  });

  test('sync repetido com o mesmo estado não reenvia ao nativo', () async {
    stubSettings(const AppSettings(snapToLayoutRegions: true));
    stubApplied({monitorKey(_monitor): _layout.id});

    final service = buildService();
    await service.start();
    await service.sync();

    verify(
      () => systemIntegration.setLayoutSnapRegions(
        enabled: true,
        regions: any(named: 'regions'),
      ),
    ).called(1);
  });
}
