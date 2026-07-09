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
    this.gap = 0,
    this.margin = 0,
  });

  final Rule rule;
  final ManagedWindow window;
  final List<Monitor> monitors;
  final double gap;
  final double margin;

  @override
  List<Object?> get props => [rule, window, monitors, gap, margin];
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

  Future<Either<Failure, bool>> _applyRegion(
    ApplyRuleParams params,
    Monitor monitor,
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

    final regions = [...layout.regions]
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    final frame = regionFrameOnMonitor(
      regions[target.$2],
      monitor,
      gap: params.gap,
      margin: params.margin,
    );
    return _windowsRepository.setWindowFrame(
      params.window,
      x: frame.x,
      y: frame.y,
      width: frame.width,
      height: frame.height,
    );
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
