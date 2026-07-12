import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/system_integration_repository.dart';
import '../datasources/system_platform_datasource.dart';

@LazySingleton(as: SystemIntegrationRepository)
class SystemIntegrationRepositoryImpl implements SystemIntegrationRepository {
  const SystemIntegrationRepositoryImpl(this._datasource);

  final SystemPlatformDatasource _datasource;

  @override
  Future<Either<Failure, Unit>> setLaunchAtLogin(bool enabled) {
    return _invoke(() => _datasource.setLaunchAtLogin(enabled));
  }

  @override
  Future<Either<Failure, Unit>> setDockVisible(bool visible) {
    return _invoke(() => _datasource.setDockVisible(visible));
  }

  @override
  Future<Either<Failure, Unit>> setStatusBarVisible(bool visible) {
    return _invoke(() => _datasource.setStatusBarVisible(visible));
  }

  @override
  Future<Either<Failure, Unit>> setMagneticSnap(bool enabled) {
    return _invoke(() => _datasource.setMagneticSnap(enabled));
  }

  @override
  Future<Either<Failure, Unit>> setLayoutSnapRegions({
    required bool enabled,
    required List<({double x, double y, double width, double height})> regions,
  }) {
    return _invoke(
      () =>
          _datasource.setLayoutSnapRegions(enabled: enabled, regions: regions),
    );
  }

  @override
  Future<Either<Failure, Unit>> setSnapExcludedApps(
    List<SnapExcludedApp> apps,
  ) {
    return _invoke(() => _datasource.setSnapExcludedApps(apps));
  }

  Future<Either<Failure, Unit>> _invoke(Future<void> Function() action) async {
    try {
      await action();
      return right(unit);
    } on PlatformDatasourceException catch (e) {
      return left(PlatformFailure(e.message, code: e.code));
    } catch (e) {
      return left(UnexpectedFailure('$e'));
    }
  }
}
