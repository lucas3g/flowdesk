import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../layouts/domain/repositories/layouts_repository.dart';
import '../../../layouts/domain/usecases/apply_layout.dart';
import '../../../monitors/domain/entities/monitor.dart';
import '../../../windows/domain/entities/managed_window.dart';
import '../../../windows/domain/repositories/windows_repository.dart';
import '../../../windows/domain/usecases/center_window.dart';
import '../../../windows/domain/usecases/maximize_window.dart';
import '../entities/rule.dart';

class ApplyRuleParams extends Equatable {
  const ApplyRuleParams({
    required this.rule,
    required this.window,
    required this.monitors,
    this.appliedLayouts = const {},
    this.gap = 0,
    this.margin = 0,
  });

  final Rule rule;
  final ManagedWindow window;
  final List<Monitor> monitors;

  /// Layout aplicado por monitor (monitorKey → layoutId) — fallback para
  /// regras de região antigas que não gravaram o monitor de destino.
  final Map<String, int> appliedLayouts;
  final double gap;
  final double margin;

  @override
  List<Object?> get props => [
    rule,
    window,
    monitors,
    appliedLayouts,
    gap,
    margin,
  ];
}

/// Executa a ação de uma regra sobre a janela recém-aberta.
@injectable
class ApplyRuleToWindow implements UseCase<bool, ApplyRuleParams> {
  const ApplyRuleToWindow(
    this._windowsRepository,
    this._layoutsRepository,
    this._centerWindow,
    this._maximizeWindow,
  );

  final WindowsRepository _windowsRepository;
  final LayoutsRepository _layoutsRepository;
  final CenterWindow _centerWindow;
  final MaximizeWindow _maximizeWindow;

  @override
  Future<Either<Failure, bool>> call(ApplyRuleParams params) async {
    if (params.monitors.isEmpty) {
      return left(const ValidationFailure('Nenhum monitor disponível.'));
    }

    final currentMonitor = _monitorOfWindow(params);

    switch (params.rule.actionType) {
      case RuleActionType.maximize:
        return _maximizeWindow(
          MaximizeParams(
            window: params.window,
            monitor: currentMonitor,
            margin: params.margin,
          ),
        );

      case RuleActionType.center:
        return _centerWindow(
          CenterParams(window: params.window, monitor: currentMonitor),
        );

      case RuleActionType.moveToMonitor:
        final target = _monitorByName(params.monitors, params.rule.targetValue);
        if (target == null) {
          return left(
            ValidationFailure(
              "Monitor '${params.rule.targetValue}' não encontrado.",
            ),
          );
        }
        return _centerWindow(
          CenterParams(window: params.window, monitor: target),
        );

      case RuleActionType.applyRegion:
        return _applyRegion(params, currentMonitor);
    }
  }

  /// Frame que a regra pretende dar à janela, ou null quando a ação não tem
  /// alvo fixo (centralizar depende do tamanho atual da janela) ou o alvo é
  /// inválido. Usado pelo engine para verificar/reaplicar após o app assentar.
  Future<RegionFrame?> targetFrame(ApplyRuleParams params) async {
    if (params.monitors.isEmpty) return null;
    final currentMonitor = _monitorOfWindow(params);

    switch (params.rule.actionType) {
      case RuleActionType.maximize:
        final monitor = currentMonitor;
        final margin = params.margin;
        return (
          x: monitor.visibleX + margin,
          y: monitor.visibleY + margin,
          width: monitor.visibleWidth - margin * 2,
          height: monitor.visibleHeight - margin * 2,
        );

      case RuleActionType.center:
      case RuleActionType.moveToMonitor:
        return null;

      case RuleActionType.applyRegion:
        return (await _regionFrame(params, currentMonitor)).toOption()
            .toNullable();
    }
  }

  Future<Either<Failure, bool>> _applyRegion(
    ApplyRuleParams params,
    Monitor windowMonitor,
  ) async {
    final frameResult = await _regionFrame(params, windowMonitor);
    return frameResult.fold(
      (failure) async => left(failure),
      (frame) => _windowsRepository.setWindowFrame(
        params.window,
        x: frame.x,
        y: frame.y,
        width: frame.width,
        height: frame.height,
      ),
    );
  }

  /// Calcula o frame da região da regra, resolvendo o monitor de destino:
  /// o monitorKey gravado na regra; senão, o monitor onde o layout da regra
  /// está aplicado; por fim, o monitor atual da janela (regras antigas).
  Future<Either<Failure, RegionFrame>> _regionFrame(
    ApplyRuleParams params,
    Monitor windowMonitor,
  ) async {
    final target = params.rule.regionTarget;
    if (target == null) {
      return left(const ValidationFailure('Alvo de região inválido.'));
    }

    final layouts = (await _layoutsRepository.getLayouts()).getOrElse(
      (_) => [],
    );
    final layout = layouts.where((l) => l.id == target.$1).firstOrNull;
    if (layout == null || target.$2 >= layout.regions.length) {
      return left(
        const ValidationFailure('A região da regra não existe mais.'),
      );
    }

    final monitor =
        _monitorByKey(params.monitors, target.$3) ??
        _monitorOfAppliedLayout(params, target.$1) ??
        windowMonitor;

    final regions = [...layout.regions]
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return right(
      regionFrameOnMonitor(
        regions[target.$2],
        monitor,
        gap: params.gap,
        margin: params.margin,
      ),
    );
  }

  Monitor? _monitorByKey(List<Monitor> monitors, String? key) {
    if (key == null || key.isEmpty) return null;
    for (final monitor in monitors) {
      if (monitorKey(monitor) == key) return monitor;
    }
    return null;
  }

  /// Monitor em que o layout da regra está aplicado, se houver.
  Monitor? _monitorOfAppliedLayout(ApplyRuleParams params, int layoutId) {
    for (final monitor in params.monitors) {
      if (params.appliedLayouts[monitorKey(monitor)] == layoutId) {
        return monitor;
      }
    }
    return null;
  }

  Monitor _monitorOfWindow(ApplyRuleParams params) {
    for (final monitor in params.monitors) {
      if (monitor.id == params.window.monitorId) return monitor;
    }
    return params.monitors.firstWhere(
      (monitor) => monitor.isPrimary,
      orElse: () => params.monitors.first,
    );
  }

  Monitor? _monitorByName(List<Monitor> monitors, String name) {
    for (final monitor in monitors) {
      if (monitor.name == name) return monitor;
    }
    return null;
  }
}
