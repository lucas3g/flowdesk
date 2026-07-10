import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../monitors/domain/entities/monitor.dart';
import '../../../windows/domain/entities/managed_window.dart';
import '../../../windows/domain/repositories/windows_repository.dart';
import '../entities/layout.dart';

/// Frame absoluto (coordenadas CG) de uma região aplicada a um monitor.
typedef RegionFrame = ({double x, double y, double width, double height});

/// Converte uma região em percentuais para um frame na área útil do monitor,
/// aplicando a margem externa e metade do espaçamento em cada lado.
RegionFrame regionFrameOnMonitor(
  LayoutRegion region,
  Monitor monitor, {
  double gap = 0,
  double margin = 0,
}) {
  final areaX = monitor.visibleX + margin;
  final areaY = monitor.visibleY + margin;
  final areaWidth = monitor.visibleWidth - margin * 2;
  final areaHeight = monitor.visibleHeight - margin * 2;
  final inset = gap / 2;

  return (
    x: areaX + region.x / 100 * areaWidth + inset,
    y: areaY + region.y / 100 * areaHeight + inset,
    width: region.width / 100 * areaWidth - gap,
    height: region.height / 100 * areaHeight - gap,
  );
}

class ApplyLayoutParams extends Equatable {
  const ApplyLayoutParams({
    required this.layout,
    required this.monitor,
    required this.windows,
    this.gap = 0,
    this.margin = 0,
  });

  final Layout layout;
  final Monitor monitor;

  /// Janelas na ordem de atribuição às regiões (a primeira vai para a
  /// primeira região, e assim por diante).
  final List<ManagedWindow> windows;
  final double gap;
  final double margin;

  @override
  List<Object?> get props => [layout, monitor, windows, gap, margin];
}

/// Aplica um layout: encaixa cada janela na região correspondente.
///
/// Regiões com app associado recebem a janela daquele app (a maior, quando
/// houver várias); as demais são preenchidas na ordem com as janelas
/// restantes. Instâncias extras de apps já vinculados a regiões não são
/// redimensionadas. Retorna quantas janelas foram posicionadas com sucesso.
@injectable
class ApplyLayout implements UseCase<int, ApplyLayoutParams> {
  const ApplyLayout(this._windowsRepository);

  final WindowsRepository _windowsRepository;

  @override
  Future<Either<Failure, int>> call(ApplyLayoutParams params) async {
    final regions = [...params.layout.regions]
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    // 1ª passada: resolve as regiões com app associado.
    final remaining = [...params.windows];
    final assignments = <(LayoutRegion, ManagedWindow)>[];

    for (final region in regions.where((r) => r.hasApp)) {
      final candidates =
          remaining
              .where((window) => window.bundleId == region.appBundleId)
              .toList()
            ..sort(
              (a, b) => (b.width * b.height).compareTo(a.width * a.height),
            );
      if (candidates.isEmpty) continue;
      final chosen = _pickWindow(region, candidates);
      assignments.add((region, chosen));
      remaining.remove(chosen);
    }

    // 2ª passada: regiões livres (ou cujo app não está aberto) recebem as
    // janelas restantes na ordem. Instâncias extras de apps já vinculados a
    // alguma região ficam de fora: se o app foi configurado, só as janelas
    // escolhidas na 1ª passada são posicionadas — as demais não são tocadas.
    final configuredBundleIds = regions
        .where((r) => r.hasApp)
        .map((r) => r.appBundleId)
        .toSet();
    final fillable = remaining
        .where((window) => !configuredBundleIds.contains(window.bundleId))
        .toList();

    final assignedRegions = assignments.map((a) => a.$1).toSet();
    for (final region in regions) {
      if (assignedRegions.contains(region) || fillable.isEmpty) continue;
      assignments.add((region, fillable.removeAt(0)));
    }

    Failure? lastFailure;
    var applied = 0;

    for (final (region, window) in assignments) {
      final frame = regionFrameOnMonitor(
        region,
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
      result.fold(
        (failure) => lastFailure = failure,
        (success) => applied += success ? 1 : 0,
      );
    }

    if (applied == 0 && lastFailure != null) return left(lastFailure!);
    return right(applied);
  }

  /// Entre as janelas do app (ordenadas da maior para a menor), prefere a
  /// instância cujo título casa com o escolhido na região: primeiro por
  /// igualdade exata, depois por conteúdo (títulos mudam com o documento
  /// aberto); sem correspondência, mantém a maior.
  ManagedWindow _pickWindow(
    LayoutRegion region,
    List<ManagedWindow> candidates,
  ) {
    if (!region.hasWindowTitle) return candidates.first;
    final wanted = region.appWindowTitle!.toLowerCase();

    for (final window in candidates) {
      if (window.title.toLowerCase() == wanted) return window;
    }
    for (final window in candidates) {
      final title = window.title.toLowerCase();
      if (title.isEmpty) continue;
      if (title.contains(wanted) || wanted.contains(title)) return window;
    }
    return candidates.first;
  }
}
