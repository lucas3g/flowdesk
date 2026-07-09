import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/history_entry.dart';
import '../../domain/repositories/history_repository.dart';
import '../datasources/history_local_datasource.dart';

@LazySingleton(as: HistoryRepository)
class HistoryRepositoryImpl implements HistoryRepository {
  const HistoryRepositoryImpl(this._datasource);

  final HistoryLocalDatasource _datasource;

  @override
  Future<Either<Failure, List<HistoryEntry>>> getEntries({
    int limit = 50,
  }) async {
    try {
      return right(await _datasource.getEntries(limit: limit));
    } on DatabaseException catch (e) {
      return left(DatabaseFailure(e.message));
    } catch (e) {
      return left(UnexpectedFailure('$e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> addEntry(HistoryEntry entry) async {
    try {
      await _datasource.addEntry(entry);
      return right(unit);
    } on DatabaseException catch (e) {
      return left(DatabaseFailure(e.message));
    } catch (e) {
      return left(UnexpectedFailure('$e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> clear() async {
    try {
      await _datasource.clear();
      return right(unit);
    } on DatabaseException catch (e) {
      return left(DatabaseFailure(e.message));
    } catch (e) {
      return left(UnexpectedFailure('$e'));
    }
  }
}
