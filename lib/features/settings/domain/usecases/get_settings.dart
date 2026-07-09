import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/app_settings.dart';
import '../repositories/settings_repository.dart';

/// Carrega as preferências do aplicativo.
@injectable
class GetSettings implements UseCase<AppSettings, NoParams> {
  const GetSettings(this._repository);

  final SettingsRepository _repository;

  @override
  Future<Either<Failure, AppSettings>> call(NoParams params) {
    return _repository.getSettings();
  }
}
