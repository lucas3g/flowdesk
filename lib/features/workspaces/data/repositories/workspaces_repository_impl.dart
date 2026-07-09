import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/workspace.dart';
import '../../domain/repositories/workspaces_repository.dart';
import '../datasources/workspaces_local_datasource.dart';

@LazySingleton(as: WorkspacesRepository)
class WorkspacesRepositoryImpl implements WorkspacesRepository {
  const WorkspacesRepositoryImpl(this._datasource);

  final WorkspacesLocalDatasource _datasource;

  @override
  Future<Either<Failure, List<Workspace>>> getWorkspaces() async {
    try {
      return right(await _datasource.getWorkspaces());
    } on DatabaseException catch (e) {
      return left(DatabaseFailure(e.message));
    } catch (e) {
      return left(UnexpectedFailure('$e'));
    }
  }

  @override
  Future<Either<Failure, Workspace>> saveWorkspace(Workspace workspace) async {
    try {
      return right(await _datasource.saveWorkspace(workspace));
    } on DatabaseException catch (e) {
      return left(DatabaseFailure(e.message));
    } catch (e) {
      return left(UnexpectedFailure('$e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteWorkspace(int workspaceId) async {
    try {
      await _datasource.deleteWorkspace(workspaceId);
      return right(unit);
    } on DatabaseException catch (e) {
      return left(DatabaseFailure(e.message));
    } catch (e) {
      return left(UnexpectedFailure('$e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> setActive(int workspaceId) async {
    try {
      await _datasource.setActive(workspaceId);
      return right(unit);
    } on DatabaseException catch (e) {
      return left(DatabaseFailure(e.message));
    } catch (e) {
      return left(UnexpectedFailure('$e'));
    }
  }
}
