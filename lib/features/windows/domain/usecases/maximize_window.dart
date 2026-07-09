import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../monitors/domain/entities/monitor.dart';
import '../entities/managed_window.dart';
import '../repositories/windows_repository.dart';

class MaximizeParams extends Equatable {
  const MaximizeParams({
    required this.window,
    required this.monitor,
    this.margin = 0,
  });

  final ManagedWindow window;
  final Monitor monitor;

  /// Margem entre a janela e as bordas da área útil, em pixels.
  final double margin;

  @override
  List<Object?> get props => [window, monitor, margin];
}

/// Maximiza a janela na área útil do monitor (sem menu bar/Dock),
/// respeitando a margem configurada.
@injectable
class MaximizeWindow implements UseCase<bool, MaximizeParams> {
  const MaximizeWindow(this._repository);

  final WindowsRepository _repository;

  @override
  Future<Either<Failure, bool>> call(MaximizeParams params) {
    final monitor = params.monitor;
    final margin = params.margin;

    return _repository.setWindowFrame(
      params.window,
      x: monitor.visibleX + margin,
      y: monitor.visibleY + margin,
      width: monitor.visibleWidth - margin * 2,
      height: monitor.visibleHeight - margin * 2,
    );
  }
}
