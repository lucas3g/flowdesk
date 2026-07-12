import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/layout.dart';
import '../../domain/repositories/layouts_repository.dart';
import '../datasources/layouts_local_datasource.dart';

@LazySingleton(as: LayoutsRepository)
class LayoutsRepositoryImpl implements LayoutsRepository {
  const LayoutsRepositoryImpl(this._datasource);

  final LayoutsLocalDatasource _datasource;

  @override
  Future<Either<Failure, List<Layout>>> getLayouts() async {
    try {
      return right(await _datasource.getLayouts());
    } on DatabaseException catch (e) {
      return left(DatabaseFailure(e.message));
    } catch (e) {
      return left(UnexpectedFailure('$e'));
    }
  }

  @override
  Future<Either<Failure, Layout>> saveLayout(Layout layout) async {
    try {
      return right(await _datasource.saveLayout(layout));
    } on DatabaseException catch (e) {
      return left(DatabaseFailure(e.message));
    } catch (e) {
      return left(UnexpectedFailure('$e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteLayout(int layoutId) async {
    try {
      await _datasource.deleteLayout(layoutId);
      return right(unit);
    } on DatabaseException catch (e) {
      return left(DatabaseFailure(e.message));
    } catch (e) {
      return left(UnexpectedFailure('$e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> setFavorite(
    int layoutId,
    bool isFavorite,
  ) async {
    try {
      await _datasource.setFavorite(layoutId, isFavorite);
      return right(unit);
    } on DatabaseException catch (e) {
      return left(DatabaseFailure(e.message));
    } catch (e) {
      return left(UnexpectedFailure('$e'));
    }
  }

  @override
  Future<Either<Failure, Map<String, int>>> getAppliedLayouts() async {
    try {
      return right(await _datasource.getAppliedLayouts());
    } on DatabaseException catch (e) {
      return left(DatabaseFailure(e.message));
    } catch (e) {
      return left(UnexpectedFailure('$e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> setAppliedLayout(
    String monitorKey,
    int layoutId,
  ) async {
    try {
      await _datasource.setAppliedLayout(monitorKey, layoutId);
      return right(unit);
    } on DatabaseException catch (e) {
      return left(DatabaseFailure(e.message));
    } catch (e) {
      return left(UnexpectedFailure('$e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> removeAppliedLayout(String monitorKey) async {
    try {
      await _datasource.removeAppliedLayout(monitorKey);
      return right(unit);
    } on DatabaseException catch (e) {
      return left(DatabaseFailure(e.message));
    } catch (e) {
      return left(UnexpectedFailure('$e'));
    }
  }
}
