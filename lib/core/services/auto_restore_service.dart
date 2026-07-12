import 'dart:async';

import 'package:injectable/injectable.dart';

import '../../features/monitors/domain/entities/monitor_profile.dart';
import '../../features/monitors/presentation/cubits/monitors_cubit.dart';
import '../../features/rules/domain/repositories/rules_repository.dart';
import '../../features/rules/presentation/cubits/rules_cubit.dart';
import '../../features/windows/domain/entities/managed_window.dart';
import '../../features/windows/domain/repositories/window_positions_repository.dart';
import '../../features/windows/domain/usecases/get_windows.dart';
import '../../features/windows/domain/usecases/move_resize_window.dart';
import '../../features/windows/presentation/cubits/windows_cubit.dart';
import '../usecases/usecase.dart';

/// Auto Restore: memoriza a posição da janela principal de cada app e a
/// restaura quando o app é reaberto na mesma configuração de monitores.
///
/// Regras ativas têm precedência — apps com regra não são restaurados.
@lazySingleton
class AutoRestoreService {
  AutoRestoreService(
    this._positionsRepository,
    this._rulesRepository,
    this._getWindows,
    this._moveResize,
    this._windowsCubit,
    this._monitorsCubit,
    this._rulesCubit,
  );

  final WindowPositionsRepository _positionsRepository;
  final RulesRepository _rulesRepository;
  final GetWindows _getWindows;
  final MoveResizeWindow _moveResize;
  final WindowsCubit _windowsCubit;
  final MonitorsCubit _monitorsCubit;
  final RulesCubit _rulesCubit;

  StreamSubscription<Object?>? _windowsSubscription;
  StreamSubscription<({String bundleId, String appName})>? _launchSubscription;

  static const Duration pollInterval = Duration(milliseconds: 600);
  static const int maxPollAttempts = 8;

  void start() {
    // Grava as posições sempre que a lista de janelas é atualizada.
    _windowsSubscription ??= _windowsCubit.stream.listen(
      (state) => _recordPositions(state.windows),
    );
    // Restaura ao reabrir um app.
    _launchSubscription ??= _rulesRepository.appLaunches().listen(
      _onAppLaunched,
    );
  }

  String get _fingerprint => monitorsFingerprint(_monitorsCubit.state.monitors);

  Future<void> _recordPositions(List<ManagedWindow> windows) async {
    final monitors = _monitorsCubit.state.monitors;
    if (monitors.isEmpty || windows.isEmpty) return;
    final fingerprint = _fingerprint;

    // Janela principal (maior) de cada app.
    final mainWindows = <String, ManagedWindow>{};
    for (final window in windows) {
      if (window.bundleId.isEmpty) continue;
      final current = mainWindows[window.bundleId];
      if (current == null ||
          window.width * window.height > current.width * current.height) {
        mainWindows[window.bundleId] = window;
      }
    }

    for (final window in mainWindows.values) {
      await _positionsRepository.savePosition(
        bundleId: window.bundleId,
        monitorFingerprint: fingerprint,
        x: window.x,
        y: window.y,
        width: window.width,
        height: window.height,
      );
    }
  }

  Future<void> _onAppLaunched(({String bundleId, String appName}) event) async {
    // Apps com regra ativa são posicionados pelo rules engine.
    final hasRule = _rulesCubit.state.rules.any(
      (rule) => rule.isActive && rule.bundleId == event.bundleId,
    );
    if (hasRule) return;

    final stored = (await _positionsRepository.getPosition(
      bundleId: event.bundleId,
      monitorFingerprint: _fingerprint,
    )).getOrElse((_) => null);
    if (stored == null) return;

    final window = await _waitForWindow(event.bundleId);
    if (window == null) return;

    await _moveResize(
      MoveResizeParams(
        window: window,
        x: stored.x,
        y: stored.y,
        width: stored.width,
        height: stored.height,
      ),
    );
  }

  Future<ManagedWindow?> _waitForWindow(String bundleId) async {
    for (var attempt = 0; attempt < maxPollAttempts; attempt++) {
      final windows = (await _getWindows(
        const NoParams(),
      )).getOrElse((_) => const []);
      final candidates =
          windows.where((window) => window.bundleId == bundleId).toList()..sort(
            (a, b) => (b.width * b.height).compareTo(a.width * a.height),
          );
      if (candidates.isNotEmpty) return candidates.first;
      await Future<void>.delayed(pollInterval);
    }
    return null;
  }
}
