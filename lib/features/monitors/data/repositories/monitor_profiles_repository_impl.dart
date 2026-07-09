import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/monitor_profile.dart';
import '../../domain/repositories/monitor_profiles_repository.dart';
import '../datasources/monitor_profiles_local_datasource.dart';

@LazySingleton(as: MonitorProfilesRepository)
class MonitorProfilesRepositoryImpl implements MonitorProfilesRepository {
  const MonitorProfilesRepositoryImpl(this._datasource);

  final MonitorProfilesLocalDatasource _datasource;

  @override
  Future<Either<Failure, List<MonitorProfile>>> getProfiles() async {
    try {
      return right(await _datasource.getProfiles());
    } on DatabaseException catch (e) {
      return left(DatabaseFailure(e.message));
    } catch (e) {
      return left(UnexpectedFailure('$e'));
    }
  }

  @override
  Future<Either<Failure, MonitorProfile>> saveProfile(
    MonitorProfile profile,
  ) async {
    try {
      return right(await _datasource.saveProfile(profile));
    } on DatabaseException catch (e) {
      return left(DatabaseFailure(e.message));
    } catch (e) {
      return left(UnexpectedFailure('$e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteProfile(int profileId) async {
    try {
      await _datasource.deleteProfile(profileId);
      return right(unit);
    } on DatabaseException catch (e) {
      return left(DatabaseFailure(e.message));
    } catch (e) {
      return left(UnexpectedFailure('$e'));
    }
  }
}
