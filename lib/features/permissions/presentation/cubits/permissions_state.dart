import 'package:equatable/equatable.dart';

import '../../domain/entities/permissions_status.dart';

enum PermissionsCheckStatus { unknown, checked, error }

/// Estado das permissões do macOS observadas pelo app.
class PermissionsState extends Equatable {
  const PermissionsState({
    this.status = PermissionsCheckStatus.unknown,
    this.permissions = const PermissionsStatus(
      accessibility: false,
      screenRecording: false,
    ),
    this.errorMessage,
  });

  final PermissionsCheckStatus status;
  final PermissionsStatus permissions;
  final String? errorMessage;

  /// Só exibe aviso após uma verificação concluída sem acessibilidade.
  bool get needsAccessibility =>
      status == PermissionsCheckStatus.checked && !permissions.accessibility;

  PermissionsState copyWith({
    PermissionsCheckStatus? status,
    PermissionsStatus? permissions,
    String? errorMessage,
  }) {
    return PermissionsState(
      status: status ?? this.status,
      permissions: permissions ?? this.permissions,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, permissions, errorMessage];
}
