import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/managed_window.dart';
import '../repositories/windows_repository.dart';

class MoveResizeParams extends Equatable {
  const MoveResizeParams({
    required this.window,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  final ManagedWindow window;
  final double x;
  final double y;
  final double width;
  final double height;

  @override
  List<Object?> get props => [window, x, y, width, height];
}

/// Move/redimensiona uma janela para um frame arbitrário.
@injectable
class MoveResizeWindow implements UseCase<bool, MoveResizeParams> {
  const MoveResizeWindow(this._repository);

  final WindowsRepository _repository;

  @override
  Future<Either<Failure, bool>> call(MoveResizeParams params) {
    return _repository.setWindowFrame(
      params.window,
      x: params.x,
      y: params.y,
      width: params.width,
      height: params.height,
    );
  }
}
