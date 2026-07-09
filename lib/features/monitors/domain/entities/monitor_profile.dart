import 'package:equatable/equatable.dart';

import 'monitor.dart';

/// Perfil vinculado a uma combinação específica de monitores.
///
/// Quando a configuração de telas conectadas corresponde ao [fingerprint],
/// o workspace/layout do perfil pode ser aplicado automaticamente.
class MonitorProfile extends Equatable {
  const MonitorProfile({
    this.id = 0,
    required this.name,
    required this.fingerprint,
    this.workspaceId,
    this.layoutId,
    this.autoApply = true,
  });

  final int id;
  final String name;

  /// Identificador estável da combinação de monitores.
  final String fingerprint;

  /// Workspace aplicado ao detectar a configuração (tem precedência).
  final int? workspaceId;

  /// Layout aplicado quando não há workspace.
  final int? layoutId;
  final bool autoApply;

  MonitorProfile copyWith({
    int? id,
    String? name,
    String? fingerprint,
    int? Function()? workspaceId,
    int? Function()? layoutId,
    bool? autoApply,
  }) {
    return MonitorProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      fingerprint: fingerprint ?? this.fingerprint,
      workspaceId: workspaceId != null ? workspaceId() : this.workspaceId,
      layoutId: layoutId != null ? layoutId() : this.layoutId,
      autoApply: autoApply ?? this.autoApply,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    fingerprint,
    workspaceId,
    layoutId,
    autoApply,
  ];
}

/// Fingerprint estável de uma combinação de monitores: nome + resolução
/// nativa de cada tela, ordenados (independente da posição/ordem).
String monitorsFingerprint(List<Monitor> monitors) {
  final parts = [
    for (final monitor in monitors)
      '${monitor.name}:${monitor.pixelWidth}x${monitor.pixelHeight}',
  ]..sort();
  return parts.join('|');
}
