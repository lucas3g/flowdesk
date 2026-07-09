import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/workspaces_repository.dart';

/// Exclui um workspace.
@injectable
class DeleteWorkspace implements UseCase<Unit, int> {
  const DeleteWorkspace(this._repository);

  final WorkspacesRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(int params) {
    return _repository.deleteWorkspace(params);
  }
}
