import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/permissions_status.dart';
import '../repositories/permissions_repository.dart';

/// Consulta a situação atual das permissões do macOS.
@injectable
class GetPermissionsStatus implements UseCase<PermissionsStatus, NoParams> {
  const GetPermissionsStatus(this._repository);

  final PermissionsRepository _repository;

  @override
  Future<Either<Failure, PermissionsStatus>> call(NoParams params) {
    return _repository.getStatus();
  }
}
