import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/app_settings.dart';
import '../repositories/settings_repository.dart';

/// Persiste as preferências do aplicativo.
@injectable
class SaveSettings implements UseCase<Unit, AppSettings> {
  const SaveSettings(this._repository);

  final SettingsRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(AppSettings params) {
    return _repository.saveSettings(params);
  }
}
