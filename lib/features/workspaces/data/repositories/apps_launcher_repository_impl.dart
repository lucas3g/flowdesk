import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/repositories/apps_launcher_repository.dart';
import '../datasources/workspace_platform_datasource.dart';

@LazySingleton(as: AppsLauncherRepository)
class AppsLauncherRepositoryImpl implements AppsLauncherRepository {
  const AppsLauncherRepositoryImpl(this._datasource);

  final WorkspacePlatformDatasource _datasource;

  @override
  Future<Either<Failure, bool>> launchApp(String bundleId) async {
    try {
      return right(await _datasource.launchApp(bundleId));
    } on PlatformDatasourceException catch (e) {
      return left(PlatformFailure(e.message, code: e.code));
    } catch (e) {
      return left(UnexpectedFailure('$e'));
    }
  }
}
