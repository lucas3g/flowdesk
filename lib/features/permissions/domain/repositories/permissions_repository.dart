import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/permissions_status.dart';

/// Contrato de acesso às permissões do macOS.
abstract interface class PermissionsRepository {
  Future<Either<Failure, PermissionsStatus>> getStatus();

  /// Exibe o prompt do sistema de Acessibilidade quando ainda não concedida.
  Future<Either<Failure, bool>> requestAccessibility();

  /// Abre a seção correspondente nas Ajustes do Sistema.
  Future<Either<Failure, Unit>> openSystemSettings(PermissionType type);
}
