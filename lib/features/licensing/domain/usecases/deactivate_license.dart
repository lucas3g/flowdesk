import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/license.dart';
import '../repositories/license_repository.dart';

/// Desativa a licença nesta instalação (libera o seat no servidor).
@injectable
class DeactivateLicense implements UseCase<License, NoParams> {
  const DeactivateLicense(this._repository);

  final LicenseRepository _repository;

  @override
  Future<Either<Failure, License>> call(NoParams params) =>
      _repository.deactivate();
}
