import 'package:bloc_test/bloc_test.dart';
import 'package:flowdesk/core/services/snap_regions_service.dart';
import 'package:flowdesk/core/usecases/usecase.dart';
import 'package:flowdesk/features/layouts/domain/entities/layout.dart';
import 'package:flowdesk/features/layouts/domain/usecases/apply_layout.dart';
import 'package:flowdesk/features/layouts/domain/usecases/get_layouts.dart';
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

const _layout = Layout(
  id: 7,
  name: 'Metades',
  regions: [
    LayoutRegion(name: 'Esq.', x: 0, y: 0, width: 50, height: 100),
    LayoutRegion(name: 'Dir.', x: 50, y: 0, width: 50, height: 100),
  ],
);

void main() {
  late _MockSettingsCubit settingsCubit;
  late _MockMonitorsCubit monitorsCubit;
  late _MockGetLayouts getLayouts;
  late _MockSystemIntegrationRepository systemIntegration;

  setUpAll(() => registerFallbackValue(const NoParams()));

  setUp(() {
    settingsCubit = _MockSettingsCubit();
    monitorsCubit = _MockMonitorsCubit();
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
    when(() => getLayouts(any())).thenAnswer((_) async => right([_layout]));
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

  test('preferência desativada envia enabled=false sem regiões', () async {
    stubSettings(const AppSettings(snapToLayoutRegions: false));

    await buildService().start();

    verify(
      () => systemIntegration.setLayoutSnapRegions(enabled: false, regions: []),
    ).called(1);
  });

  test('sem layout aplicado envia enabled=false', () async {
    stubSettings(const AppSettings(snapToLayoutRegions: true));

    await buildService().start();

    verify(
      () => systemIntegration.setLayoutSnapRegions(enabled: false, regions: []),
    ).called(1);
  });

  test('ativada envia os frames das regiões no monitor do apply', () async {
    stubSettings(
      const AppSettings(
        snapToLayoutRegions: true,
        lastAppliedLayoutId: 7,
        lastAppliedMonitorId: 1,
      ),
    );

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

  test('layout inexistente envia enabled=false', () async {
    stubSettings(
      const AppSettings(
        snapToLayoutRegions: true,
        lastAppliedLayoutId: 99,
        lastAppliedMonitorId: 1,
      ),
    );

    await buildService().start();

    verify(
      () => systemIntegration.setLayoutSnapRegions(enabled: false, regions: []),
    ).called(1);
  });

  test('monitor do apply desconectado envia enabled=false', () async {
    stubSettings(
      const AppSettings(
        snapToLayoutRegions: true,
        lastAppliedLayoutId: 7,
        lastAppliedMonitorId: 99,
      ),
    );

    await buildService().start();

    verify(
      () => systemIntegration.setLayoutSnapRegions(enabled: false, regions: []),
    ).called(1);
  });

  test('sync repetido com o mesmo estado não reenvia ao nativo', () async {
    stubSettings(
      const AppSettings(
        snapToLayoutRegions: true,
        lastAppliedLayoutId: 7,
        lastAppliedMonitorId: 1,
      ),
    );

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
