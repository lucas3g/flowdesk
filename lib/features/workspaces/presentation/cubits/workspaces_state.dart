import 'package:equatable/equatable.dart';

import '../../domain/entities/workspace.dart';

enum WorkspacesStatus { loading, ready, error }

/// Estado da tela de workspaces.
class WorkspacesState extends Equatable {
  const WorkspacesState({
    this.status = WorkspacesStatus.loading,
    this.workspaces = const [],
    this.applyingId,
    this.errorMessage,
    this.feedback,
  });

  final WorkspacesStatus status;
  final List<Workspace> workspaces;

  /// Workspace sendo aplicado no momento (spinner no botão).
  final int? applyingId;
  final String? errorMessage;

  /// Mensagem transitória para snackbar.
  final String? feedback;

  WorkspacesState copyWith({
    WorkspacesStatus? status,
    List<Workspace>? workspaces,
    int? Function()? applyingId,
    String? errorMessage,
    String? feedback,
  }) {
    return WorkspacesState(
      status: status ?? this.status,
      workspaces: workspaces ?? this.workspaces,
      applyingId: applyingId != null ? applyingId() : this.applyingId,
      errorMessage: errorMessage,
      feedback: feedback,
    );
  }

  @override
  List<Object?> get props => [
    status,
    workspaces,
    applyingId,
    errorMessage,
    feedback,
  ];
}
