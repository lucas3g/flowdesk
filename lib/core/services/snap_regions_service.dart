import 'dart:async';

import 'package:injectable/injectable.dart';

import '../../features/layouts/domain/entities/layout.dart';
import '../../features/layouts/domain/usecases/apply_layout.dart';
import '../../features/layouts/domain/usecases/get_layouts.dart';
import '../../features/layouts/presentation/cubits/applied_layouts_cubit.dart';
import '../../features/monitors/domain/entities/monitor.dart';
import '../../features/monitors/presentation/cubits/monitors_cubit.dart';
import '../../features/settings/domain/repositories/system_integration_repository.dart';
import '../../features/settings/presentation/cubits/settings_cubit.dart';
import '../usecases/usecase.dart';

/// Sincroniza com o nativo as zonas de encaixe dos layouts aplicados:
/// quando a preferência está ativa, as regiões do layout de cada monitor
/// viram alvos de arrasto no SnapManager — cada monitor conectado exibe
/// as zonas do layout que foi aplicado nele.
@lazySingleton
class SnapRegionsService {
  SnapRegionsService(
    this._settingsCubit,
    this._monitorsCubit,
    this._appliedLayoutsCubit,
    this._getLayouts,
    this._systemIntegration,
  );

  final SettingsCubit _settingsCubit;
  final MonitorsCubit _monitorsCubit;
  final AppliedLayoutsCubit _appliedLayoutsCubit;
  final GetLayouts _getLayouts;
  final SystemIntegrationRepository _systemIntegration;

  StreamSubscription<Object?>? _settingsSubscription;
  StreamSubscription<Object?>? _monitorsSubscription;
  StreamSubscription<Object?>? _appliedSubscription;

  /// Assinatura do último envio, para evitar chamadas redundantes ao nativo.
  String? _lastPayload;

  /// Sincroniza o estado atual e passa a reagir a mudanças de preferências
  /// (toggle, gap/margem), de layouts aplicados e de geometria dos monitores.
  Future<void> start() async {
    _settingsSubscription ??= _settingsCubit.stream.listen((_) => sync());
    _monitorsSubscription ??= _monitorsCubit.stream.listen((_) => sync());
    _appliedSubscription ??= _appliedLayoutsCubit.stream.listen((_) => sync());
    await sync();
  }

  Future<void> sync() async {
    final settings = _settingsCubit.state.settings;
    final applied = _appliedLayoutsCubit.state;

    if (!settings.snapToLayoutRegions || applied.isEmpty) {
      await _send(enabled: false, regions: const []);
      return;
    }

    final layoutsResult = await _getLayouts(const NoParams());
    final layouts = layoutsResult.getOrElse((_) => const []);

    // União das zonas: cada monitor conectado contribui com as regiões do
    // layout aplicado nele; monitores desconectados ficam de fora até voltar.
    final frames = <({double x, double y, double width, double height})>[];
    for (final monitor in _monitorsCubit.state.monitors) {
      final layoutId = applied[monitorKey(monitor)];
      if (layoutId == null) continue;

      final layout = layouts
          .where((Layout layout) => layout.id == layoutId)
          .firstOrNull;
      if (layout == null || layout.regions.isEmpty) continue;

      for (final region in layout.regions) {
        frames.add(
          regionFrameOnMonitor(
            region,
            monitor,
            gap: settings.windowGap,
            margin: settings.screenMargin,
          ),
        );
      }
    }

    await _send(enabled: frames.isNotEmpty, regions: frames);
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
