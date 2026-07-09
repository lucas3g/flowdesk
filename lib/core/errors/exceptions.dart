/// Exceções lançadas pelas datasources e convertidas em [Failure]
/// pelas implementações de repository.
sealed class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// Erro vindo da camada nativa (MethodChannel/Swift).
class PlatformDatasourceException extends AppException {
  const PlatformDatasourceException(super.message, {this.code});

  final String? code;
}

/// Erro vindo da persistência local (Drift).
class DatabaseException extends AppException {
  const DatabaseException(super.message);
}
