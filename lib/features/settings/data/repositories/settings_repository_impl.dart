import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_local_datasource.dart';
import '../models/settings_mapper.dart';

@LazySingleton(as: SettingsRepository)
class SettingsRepositoryImpl implements SettingsRepository {
  const SettingsRepositoryImpl(this._datasource);

  final SettingsLocalDatasource _datasource;

  @override
  Future<Either<Failure, AppSettings>> getSettings() async {
    try {
      final row = await _datasource.getSettings();
      return right(row.toEntity());
    } on DatabaseException catch (e) {
      return left(DatabaseFailure(e.message));
    } catch (e) {
      return left(UnexpectedFailure('$e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> saveSettings(AppSettings settings) async {
    try {
      await _datasource.saveSettings(settings.toCompanion());
      return right(unit);
    } on DatabaseException catch (e) {
      return left(DatabaseFailure(e.message));
    } catch (e) {
      return left(UnexpectedFailure('$e'));
    }
  }
}
