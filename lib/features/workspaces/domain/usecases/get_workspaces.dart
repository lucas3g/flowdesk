import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/workspace.dart';
import '../repositories/workspaces_repository.dart';

/// Lista todos os workspaces.
@injectable
class GetWorkspaces implements UseCase<List<Workspace>, NoParams> {
  const GetWorkspaces(this._repository);

  final WorkspacesRepository _repository;

  @override
  Future<Either<Failure, List<Workspace>>> call(NoParams params) {
    return _repository.getWorkspaces();
  }
}
