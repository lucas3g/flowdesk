import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/license.dart';
import '../repositories/license_repository.dart';

/// Ativa uma license key comprada no Paddle nesta instalação.
@injectable
class ActivateLicense implements UseCase<License, String> {
  const ActivateLicense(this._repository);

  final LicenseRepository _repository;

  @override
  Future<Either<Failure, License>> call(String params) {
    final key = params.trim();
    if (key.isEmpty) {
      return Future.value(
        left(const ValidationFailure('Informe a chave de licença')),
      );
    }
    return _repository.activate(key);
  }
}
