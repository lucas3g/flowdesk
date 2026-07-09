import 'package:equatable/equatable.dart';

/// Permissões do macOS utilizadas pelo FlowDesk.
enum PermissionType { accessibility, screenRecording, automation }

/// Situação atual das permissões concedidas ao app.
class PermissionsStatus extends Equatable {
  const PermissionsStatus({
    required this.accessibility,
    required this.screenRecording,
  });

  /// Necessária para mover/redimensionar janelas (AXUIElement).
  final bool accessibility;

  /// Necessária apenas para recursos que leem conteúdo da tela.
  final bool screenRecording;

  /// O app só é funcional com a permissão de Acessibilidade.
  bool get isOperational => accessibility;

  @override
  List<Object?> get props => [accessibility, screenRecording];
}
