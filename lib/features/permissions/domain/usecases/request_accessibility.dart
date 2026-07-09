import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/permissions_repository.dart';

/// Solicita a permissão de Acessibilidade exibindo o prompt do sistema.
@injectable
class RequestAccessibility implements UseCase<bool, NoParams> {
  const RequestAccessibility(this._repository);

  final PermissionsRepository _repository;

  @override
  Future<Either<Failure, bool>> call(NoParams params) {
    return _repository.requestAccessibility();
  }
}
