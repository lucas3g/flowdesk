import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/managed_window.dart';
import '../repositories/windows_repository.dart';

/// Traz a janela para frente e ativa o aplicativo dono.
@injectable
class FocusWindow implements UseCase<bool, ManagedWindow> {
  const FocusWindow(this._repository);

  final WindowsRepository _repository;

  @override
  Future<Either<Failure, bool>> call(ManagedWindow params) {
    return _repository.focusWindow(params);
  }
}
