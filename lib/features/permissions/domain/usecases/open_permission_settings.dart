import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/permissions_status.dart';
import '../repositories/permissions_repository.dart';

/// Abre a seção da permissão nas Ajustes do Sistema para o usuário conceder.
@injectable
class OpenPermissionSettings implements UseCase<Unit, PermissionType> {
  const OpenPermissionSettings(this._repository);

  final PermissionsRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(PermissionType params) {
    return _repository.openSystemSettings(params);
  }
}
