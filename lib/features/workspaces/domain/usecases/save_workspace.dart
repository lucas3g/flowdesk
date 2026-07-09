import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/workspace.dart';
import '../repositories/workspaces_repository.dart';

/// Insere ou atualiza um workspace.
@injectable
class SaveWorkspace implements UseCase<Workspace, Workspace> {
  const SaveWorkspace(this._repository);

  final WorkspacesRepository _repository;

  @override
  Future<Either<Failure, Workspace>> call(Workspace params) {
    if (params.name.trim().isEmpty) {
      return Future.value(
        left(const ValidationFailure('O workspace precisa de um nome.')),
      );
    }
    return _repository.saveWorkspace(params);
  }
}
