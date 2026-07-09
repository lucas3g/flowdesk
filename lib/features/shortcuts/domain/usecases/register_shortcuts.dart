import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/shortcut_binding.dart';
import '../repositories/shortcuts_repository.dart';

/// Registra o conjunto atual de atalhos globais.
@injectable
class RegisterShortcuts implements UseCase<Unit, List<ShortcutBinding>> {
  const RegisterShortcuts(this._repository);

  final ShortcutsRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(List<ShortcutBinding> params) {
    return _repository.registerAll(params);
  }
}
