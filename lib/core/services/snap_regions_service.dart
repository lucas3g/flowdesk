import 'dart:async';

import 'package:injectable/injectable.dart';

import '../../features/layouts/domain/usecases/apply_layout.dart';
import '../../features/layouts/domain/usecases/get_layouts.dart';
import '../../features/monitors/presentation/cubits/monitors_cubit.dart';
import '../../features/settings/domain/repositories/system_integration_repository.dart';
import '../../features/settings/presentation/cubits/settings_cubit.dart';
import '../usecases/usecase.dart';

/// Sincroniza com o nativo as zonas de encaixe do último layout aplicado:
/// quando a preferência está ativa, as regiões do layout viram alvos de
/// arrasto no SnapManager — apenas no monitor em que ele foi aplicado.
@lazySingleton
class SnapRegionsService {
  SnapRegionsService(
    this._settingsCubit,
    this._monitorsCubit,
    this._getLayouts,
    this._systemIntegration,
  );

  final SettingsCubit _settingsCubit;
  final MonitorsCubit _monitorsCubit;
  final GetLayouts _getLayouts;
  final SystemIntegrationRepository _systemIntegration;

  StreamSubscription<Object?>? _settingsSubscription;
  StreamSubscription<Object?>? _monitorsSubscription;

  /// Assinatura do último envio, para evitar chamadas redundantes ao nativo.
  String? _lastPayload;

  /// Sincroniza o estado atual e passa a reagir a mudanças de preferências
  /// (toggle, layout aplicado, gap/margem) e de geometria dos monitores.
  Future<void> start() async {
    _settingsSubscription ??= _settingsCubit.stream.listen((_) => sync());
    _monitorsSubscription ??= _monitorsCubit.stream.listen((_) => sync());
    await sync();
  }

  Future<void> sync() async {
    final settings = _settingsCubit.state.settings;
    final layoutId = settings.lastAppliedLayoutId;

    if (!settings.snapToLayoutRegions || layoutId == null) {
      await _send(enabled: false, regions: const []);
      return;
    }

    final layoutsResult = await _getLayouts(const NoParams());
    final layout = layoutsResult
        .getOrElse((_) => const [])
        .where((layout) => layout.id == layoutId)
        .firstOrNull;

    // As zonas só aparecem no monitor em que o layout foi aplicado.
    final monitors = _monitorsCubit.state.monitors;
    final monitor = monitors
        .where((monitor) => monitor.id == settings.lastAppliedMonitorId)
        .firstOrNull;

    if (layout == null || layout.regions.isEmpty || monitor == null) {
      await _send(enabled: false, regions: const []);
      return;
    }

    final frames = <({double x, double y, double width, double height})>[
      for (final region in layout.regions)
        regionFrameOnMonitor(
          region,
          monitor,
          gap: settings.windowGap,
          margin: settings.screenMargin,
        ),
    ];
    await _send(enabled: true, regions: frames);
  }

  Future<void> _send({
    required bool enabled,
    required List<({double x, double y, double width, double height})> regions,
  }) async {
    final payload =
        '$enabled|${regions.map((r) => '${r.x},${r.y},${r.width},${r.height}').join(';')}';
    if (payload == _lastPayload) return;
    _lastPayload = payload;

    await _systemIntegration.setLayoutSnapRegions(
      enabled: enabled,
      regions: regions,
    );
  }
}
