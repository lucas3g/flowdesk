import 'package:equatable/equatable.dart';

import '../../../monitors/domain/entities/monitor.dart';
import '../../domain/entities/managed_window.dart';

enum WindowsStatus { loading, ready, error }

/// Estado da lista de janelas, filtros (tab por monitor) e busca.
class WindowsState extends Equatable {
  const WindowsState({
    this.status = WindowsStatus.loading,
    this.windows = const [],
    this.monitors = const [],
    this.selectedMonitorId,
    this.query = '',
    this.errorMessage,
  });

  final WindowsStatus status;
  final List<ManagedWindow> windows;

  /// Monitores conhecidos, para montar as tabs e agrupar janelas.
  final List<Monitor> monitors;

  /// Tab ativa (null = "Todos").
  final int? selectedMonitorId;
  final String query;
  final String? errorMessage;

  /// Janelas após aplicar tab e busca.
  List<ManagedWindow> get filtered {
    final lowerQuery = query.trim().toLowerCase();
    return windows.where((window) {
      if (selectedMonitorId != null &&
          window.monitorId != selectedMonitorId) {
        return false;
      }
      if (lowerQuery.isEmpty) return true;
      return window.displayTitle.toLowerCase().contains(lowerQuery) ||
          window.appName.toLowerCase().contains(lowerQuery);
    }).toList(growable: false);
  }

  /// Contagem de janelas por monitor (sem filtro de busca), para as tabs.
  int countForMonitor(int monitorId) =>
      windows.where((window) => window.monitorId == monitorId).length;

  WindowsState copyWith({
    WindowsStatus? status,
    List<ManagedWindow>? windows,
    List<Monitor>? monitors,
    int? Function()? selectedMonitorId,
    String? query,
    String? errorMessage,
  }) {
    return WindowsState(
      status: status ?? this.status,
      windows: windows ?? this.windows,
      monitors: monitors ?? this.monitors,
      selectedMonitorId: selectedMonitorId != null
          ? selectedMonitorId()
          : this.selectedMonitorId,
      query: query ?? this.query,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    windows,
    monitors,
    selectedMonitorId,
    query,
    errorMessage,
  ];
}
