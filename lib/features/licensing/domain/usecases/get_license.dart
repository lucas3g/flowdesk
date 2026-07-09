import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/license.dart';
import '../repositories/license_repository.dart';

/// Licença em cache local, sem tocar na rede.
@injectable
class GetLicense implements UseCase<License, NoParams> {
  const GetLicense(this._repository);

  final LicenseRepository _repository;

  @override
  Future<Either<Failure, License>> call(NoParams params) =>
      _repository.getLicense();
}
