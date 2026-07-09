import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/permissions_status.dart';
import '../../domain/repositories/permissions_repository.dart';
import '../datasources/permissions_platform_datasource.dart';
import '../models/permissions_status_model.dart';

@LazySingleton(as: PermissionsRepository)
class PermissionsRepositoryImpl implements PermissionsRepository {
  const PermissionsRepositoryImpl(this._datasource);

  final PermissionsPlatformDatasource _datasource;

  @override
  Future<Either<Failure, PermissionsStatus>> getStatus() async {
    try {
      final map = await _datasource.getStatus();
      return right(PermissionsStatusModel.fromMap(map));
    } on PlatformDatasourceException catch (e) {
      return left(PlatformFailure(e.message, code: e.code));
    } catch (e) {
      return left(UnexpectedFailure('$e'));
    }
  }

  @override
  Future<Either<Failure, bool>> requestAccessibility() async {
    try {
      return right(await _datasource.requestAccessibility());
    } on PlatformDatasourceException catch (e) {
      return left(PlatformFailure(e.message, code: e.code));
    } catch (e) {
      return left(UnexpectedFailure('$e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> openSystemSettings(PermissionType type) async {
    try {
      await _datasource.openSystemSettings(type.channelName);
      return right(unit);
    } on PlatformDatasourceException catch (e) {
      return left(PlatformFailure(e.message, code: e.code));
    } catch (e) {
      return left(UnexpectedFailure('$e'));
    }
  }
}
