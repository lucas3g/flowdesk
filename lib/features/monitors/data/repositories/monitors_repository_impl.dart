import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/monitor.dart';
import '../../domain/repositories/monitors_repository.dart';
import '../datasources/monitors_platform_datasource.dart';
import '../models/monitor_model.dart';

@LazySingleton(as: MonitorsRepository)
class MonitorsRepositoryImpl implements MonitorsRepository {
  const MonitorsRepositoryImpl(this._datasource);

  final MonitorsPlatformDatasource _datasource;

  @override
  Future<Either<Failure, List<Monitor>>> getMonitors() async {
    try {
      final payload = await _datasource.getMonitors();
      return right(MonitorModel.listFromChannel(payload));
    } on PlatformDatasourceException catch (e) {
      return left(PlatformFailure(e.message, code: e.code));
    } catch (e) {
      return left(UnexpectedFailure('$e'));
    }
  }

  @override
  Stream<Either<Failure, List<Monitor>>> watchMonitors() async* {
    try {
      await for (final payload in _datasource.watchMonitors()) {
        yield right(MonitorModel.listFromChannel(payload));
      }
    } on PlatformDatasourceException catch (e) {
      yield left(PlatformFailure(e.message, code: e.code));
    } catch (e) {
      yield left(UnexpectedFailure('$e'));
    }
  }
}
