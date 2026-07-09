import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../monitors/domain/entities/monitor.dart';
import '../entities/managed_window.dart';
import '../repositories/windows_repository.dart';

class CenterParams extends Equatable {
  const CenterParams({
    required this.window,
    required this.monitor,
    this.widthFraction = 0.62,
    this.heightFraction = 0.7,
  });

  final ManagedWindow window;
  final Monitor monitor;

  /// Fração da área útil ocupada pela janela centralizada.
  final double widthFraction;
  final double heightFraction;

  @override
  List<Object?> get props => [window, monitor, widthFraction, heightFraction];
}

/// Centraliza a janela na área útil do monitor (Central Focus).
@injectable
class CenterWindow implements UseCase<bool, CenterParams> {
  const CenterWindow(this._repository);

  final WindowsRepository _repository;

  @override
  Future<Either<Failure, bool>> call(CenterParams params) {
    final monitor = params.monitor;
    final width = monitor.visibleWidth * params.widthFraction;
    final height = monitor.visibleHeight * params.heightFraction;

    return _repository.setWindowFrame(
      params.window,
      x: monitor.visibleX + (monitor.visibleWidth - width) / 2,
      y: monitor.visibleY + (monitor.visibleHeight - height) / 2,
      width: width,
      height: height,
    );
  }
}
