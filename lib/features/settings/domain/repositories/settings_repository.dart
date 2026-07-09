import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/app_settings.dart';

/// Contrato de acesso às preferências do aplicativo.
abstract interface class SettingsRepository {
  Future<Either<Failure, AppSettings>> getSettings();

  Future<Either<Failure, Unit>> saveSettings(AppSettings settings);
}
