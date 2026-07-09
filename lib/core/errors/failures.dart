import 'package:equatable/equatable.dart';

/// Falha base retornada pelos use cases e repositories via `Either<Failure, T>`.
sealed class Failure extends Equatable {
  const Failure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

/// Falha originada na camada nativa (MethodChannel/Swift).
class PlatformFailure extends Failure {
  const PlatformFailure(super.message, {this.code});

  final String? code;

  @override
  List<Object?> get props => [message, code];
}

/// Falha originada na persistência local (Drift).
class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message);
}

/// Permissão do macOS ausente (Accessibility, Screen Recording, etc.).
class PermissionFailure extends Failure {
  const PermissionFailure(super.message, {required this.permission});

  final String permission;

  @override
  List<Object?> get props => [message, permission];
}

/// Falha de validação de dados de entrada.
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// Falha de comunicação com serviços remotos (API de licenças).
class NetworkFailure extends Failure {
  const NetworkFailure(super.message, {this.statusCode});

  final int? statusCode;

  @override
  List<Object?> get props => [message, statusCode];
}

/// Falha inesperada não mapeada.
class UnexpectedFailure extends Failure {
  const UnexpectedFailure(super.message);
}
