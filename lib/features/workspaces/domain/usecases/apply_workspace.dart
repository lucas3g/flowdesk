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
import '../entities/workspace.dart';
import '../repositories/apps_launcher_repository.dart';
import '../repositories/workspaces_repository.dart';

class ApplyWorkspaceParams extends Equatable {
  const ApplyWorkspaceParams({
    required this.workspace,
    required this.monitor,
    this.gap = 0,
    this.margin = 0,
    this.pollInterval = const Duration(milliseconds: 500),
    this.maxPollAttempts = 20,
  });

  final Workspace workspace;
  final Monitor monitor;
  final double gap;
  final double margin;

  /// Intervalo e limite do polling que aguarda as janelas dos apps
  /// recém-abertos aparecerem.
  final Duration pollInterval;
  final int maxPollAttempts;

  @override
  List<Object?> get props => [
    workspace,
    monitor,
    gap,
    margin,
    pollInterval,
    maxPollAttempts,
  ];
}

/// Resultado da aplicação de um workspace.
class ApplyWorkspaceResult extends Equatable {
  const ApplyWorkspaceResult({
    required this.positioned,
    required this.missingApps,
  });

  /// Quantas janelas foram posicionadas.
  final int positioned;

  /// Apps que não abriram (não instalados ou sem janela dentro do timeout).
  final List<String> missingApps;

  @override
  List<Object?> get props => [positioned, missingApps];
}

/// Aplica um workspace: abre os apps que faltam, aguarda suas janelas e
/// posiciona cada uma na região correspondente do layout vinculado.
@injectable
class ApplyWorkspace
    implements UseCase<ApplyWorkspaceResult, ApplyWorkspaceParams> {
  const ApplyWorkspace(
    this._layoutsRepository,
    this._windowsRepository,
    this._launcher,
    this._workspacesRepository,
  );

  final LayoutsRepository _layoutsRepository;
  final WindowsRepository _windowsRepository;
  final AppsLauncherRepository _launcher;
  final WorkspacesRepository _workspacesRepository;

  @override
  Future<Either<Failure, ApplyWorkspaceResult>> call(
    ApplyWorkspaceParams params,
  ) async {
    final workspace = params.workspace;
    if (workspace.apps.isEmpty) {
      return left(const ValidationFailure('O workspace não possui apps.'));
    }
    if (workspace.layoutId == null) {
      return left(
        const ValidationFailure('O workspace não possui layout vinculado.'),
      );
    }

    // 1. Layout vinculado.
    final layoutsResult = await _layoutsRepository.getLayouts();
    final layouts = layoutsResult.getOrElse((_) => []);
    final layout = layouts
        .where((l) => l.id == workspace.layoutId)
        .firstOrNull;
    if (layout == null) {
      return left(
        const ValidationFailure('O layout do workspace não existe mais.'),
      );
    }

    // 2. Abre os apps que ainda não têm janela.
    var windows = await _currentWindows();
    final sortedApps = [...workspace.apps]
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    final pending = <String>{};
    for (final app in sortedApps) {
      if (_windowOf(windows, app.bundleId) == null) {
        final launched = await _launcher.launchApp(app.bundleId);
        if (launched.getOrElse((_) => false)) {
          pending.add(app.bundleId);
        }
      }
    }

    // 3. Aguarda as janelas dos apps recém-abertos.
    var attempts = 0;
    while (pending.isNotEmpty && attempts < params.maxPollAttempts) {
      await Future<void>.delayed(params.pollInterval);
      windows = await _currentWindows();
      pending.removeWhere(
        (bundleId) => _windowOf(windows, bundleId) != null,
      );
      attempts++;
    }

    // 4. Posiciona: app i → região i.
    final regions = [...layout.regions]
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    var positioned = 0;
    final missing = <String>[];

    for (var i = 0; i < sortedApps.length && i < regions.length; i++) {
      final window = _windowOf(windows, sortedApps[i].bundleId);
      if (window == null) {
        missing.add(sortedApps[i].appName);
        continue;
      }
      final frame = regionFrameOnMonitor(
        regions[i],
        params.monitor,
        gap: params.gap,
        margin: params.margin,
      );
      final result = await _windowsRepository.setWindowFrame(
        window,
        x: frame.x,
        y: frame.y,
        width: frame.width,
        height: frame.height,
      );
      if (result.getOrElse((_) => false)) positioned++;
    }

    // 5. Marca como ativo se algo foi posicionado.
    if (positioned > 0 && workspace.id != 0) {
      await _workspacesRepository.setActive(workspace.id);
    }

    return right(
      ApplyWorkspaceResult(positioned: positioned, missingApps: missing),
    );
  }

  Future<List<ManagedWindow>> _currentWindows() async {
    final result = await _windowsRepository.getWindows();
    return result.getOrElse((_) => const []);
  }

  /// Primeira janela do app, preferindo as maiores (janela principal).
  ManagedWindow? _windowOf(List<ManagedWindow> windows, String bundleId) {
    final candidates = windows
        .where((window) => window.bundleId == bundleId)
        .toList();
    if (candidates.isEmpty) return null;
    candidates.sort(
      (a, b) => (b.width * b.height).compareTo(a.width * a.height),
    );
    return candidates.first;
  }
}
