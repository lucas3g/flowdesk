import 'package:equatable/equatable.dart';

/// App que compõe um workspace, na ordem de atribuição às regiões do layout.
class WorkspaceApp extends Equatable {
  const WorkspaceApp({
    this.id = 0,
    required this.bundleId,
    required this.appName,
    this.sortOrder = 0,
  });

  final int id;
  final String bundleId;
  final String appName;
  final int sortOrder;

  @override
  List<Object?> get props => [id, bundleId, appName, sortOrder];
}

/// Workspace: conjunto de apps + layout que os organiza.
class Workspace extends Equatable {
  const Workspace({
    this.id = 0,
    required this.name,
    this.emoji = '💻',
    this.gradientStartHex = '#0A84FF',
    this.gradientEndHex = '#40C8E0',
    this.shortcut,
    this.layoutId,
    this.isActive = false,
    this.sortOrder = 0,
    this.apps = const [],
  });

  /// 0 indica workspace ainda não persistido.
  final int id;
  final String name;
  final String emoji;
  final String gradientStartHex;
  final String gradientEndHex;

  /// Atalho de exibição (ex.: `⌃1`).
  final String? shortcut;

  /// Layout aplicado ao ativar o workspace.
  final int? layoutId;
  final bool isActive;
  final int sortOrder;
  final List<WorkspaceApp> apps;

  Workspace copyWith({
    int? id,
    String? name,
    String? emoji,
    String? gradientStartHex,
    String? gradientEndHex,
    String? Function()? shortcut,
    int? Function()? layoutId,
    bool? isActive,
    int? sortOrder,
    List<WorkspaceApp>? apps,
  }) {
    return Workspace(
      id: id ?? this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      gradientStartHex: gradientStartHex ?? this.gradientStartHex,
      gradientEndHex: gradientEndHex ?? this.gradientEndHex,
      shortcut: shortcut != null ? shortcut() : this.shortcut,
      layoutId: layoutId != null ? layoutId() : this.layoutId,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
      apps: apps ?? this.apps,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    emoji,
    gradientStartHex,
    gradientEndHex,
    shortcut,
    layoutId,
    isActive,
    sortOrder,
    apps,
  ];
}
