import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/workspace.dart';

/// Contrato de persistência de workspaces.
abstract interface class WorkspacesRepository {
  /// Lista todos (semeia os exemplos na primeira execução).
  Future<Either<Failure, List<Workspace>>> getWorkspaces();

  Future<Either<Failure, Workspace>> saveWorkspace(Workspace workspace);

  Future<Either<Failure, Unit>> deleteWorkspace(int workspaceId);

  /// Marca um workspace como ativo (desativando os demais).
  Future<Either<Failure, Unit>> setActive(int workspaceId);
}
