import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/license.dart';
import '../repositories/license_repository.dart';

/// Revalida a licença com o servidor (renova o entitlement em cache).
@injectable
class RefreshLicense implements UseCase<License, NoParams> {
  const RefreshLicense(this._repository);

  final LicenseRepository _repository;

  @override
  Future<Either<Failure, License>> call(NoParams params) =>
      _repository.refresh();
}
