import 'package:equatable/equatable.dart';

import '../../domain/entities/monitor.dart';

enum MonitorsStatus { loading, ready, error }

/// Estado da lista de monitores e da seleção na tela.
class MonitorsState extends Equatable {
  const MonitorsState({
    this.status = MonitorsStatus.loading,
    this.monitors = const [],
    this.selectedId,
    this.errorMessage,
  });

  final MonitorsStatus status;
  final List<Monitor> monitors;

  /// Monitor selecionado na visualização (null = nenhum).
  final int? selectedId;
  final String? errorMessage;

  Monitor? get selected {
    for (final monitor in monitors) {
      if (monitor.id == selectedId) return monitor;
    }
    return null;
  }

  /// Largura total do conjunto em pixels (ex.: "6.720 px de largura").
  int get totalPixelWidth =>
      monitors.fold(0, (sum, monitor) => sum + monitor.pixelWidth);

  MonitorsState copyWith({
    MonitorsStatus? status,
    List<Monitor>? monitors,
    int? Function()? selectedId,
    String? errorMessage,
  }) {
    return MonitorsState(
      status: status ?? this.status,
      monitors: monitors ?? this.monitors,
      selectedId: selectedId != null ? selectedId() : this.selectedId,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, monitors, selectedId, errorMessage];
}
