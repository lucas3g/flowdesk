import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/repositories/window_positions_repository.dart';
import '../datasources/window_positions_local_datasource.dart';

@LazySingleton(as: WindowPositionsRepository)
class WindowPositionsRepositoryImpl implements WindowPositionsRepository {
  const WindowPositionsRepositoryImpl(this._datasource);

  final WindowPositionsLocalDatasource _datasource;

  @override
  Future<Either<Failure, Unit>> savePosition({
    required String bundleId,
    required String monitorFingerprint,
    required double x,
    required double y,
    required double width,
    required double height,
  }) async {
    try {
      await _datasource.upsert(
        bundleId: bundleId,
        monitorFingerprint: monitorFingerprint,
        x: x,
        y: y,
        width: width,
        height: height,
      );
      return right(unit);
    } on DatabaseException catch (e) {
      return left(DatabaseFailure(e.message));
    } catch (e) {
      return left(UnexpectedFailure('$e'));
    }
  }

  @override
  Future<Either<Failure, StoredWindowPosition?>> getPosition({
    required String bundleId,
    required String monitorFingerprint,
  }) async {
    try {
      final row = await _datasource.find(
        bundleId: bundleId,
        monitorFingerprint: monitorFingerprint,
      );
      if (row == null) return right(null);
      return right((x: row.x, y: row.y, width: row.width, height: row.height));
    } on DatabaseException catch (e) {
      return left(DatabaseFailure(e.message));
    } catch (e) {
      return left(UnexpectedFailure('$e'));
    }
  }
}
