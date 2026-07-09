import 'package:drift/drift.dart';

import '../../../../core/services/database/app_database.dart';
import '../../domain/entities/workspace.dart';

/// Conversões entre linhas do banco e entidades de workspace.
abstract final class WorkspaceMapper {
  static Workspace fromRows(WorkspaceRow row, List<WorkspaceAppRow> apps) {
    final sorted = [...apps]
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return Workspace(
      id: row.id,
      name: row.name,
      emoji: row.emoji,
      gradientStartHex: row.gradientStartHex,
      gradientEndHex: row.gradientEndHex,
      shortcut: row.shortcut,
      layoutId: row.layoutId,
      isActive: row.isActive,
      sortOrder: row.sortOrder,
      apps: [
        for (final app in sorted)
          WorkspaceApp(
            id: app.id,
            bundleId: app.bundleId,
            appName: app.appName,
            sortOrder: app.sortOrder,
          ),
      ],
    );
  }

  static WorkspacesCompanion toCompanion(Workspace workspace) {
    return WorkspacesCompanion(
      id: workspace.id == 0 ? const Value.absent() : Value(workspace.id),
      name: Value(workspace.name),
      emoji: Value(workspace.emoji),
      gradientStartHex: Value(workspace.gradientStartHex),
      gradientEndHex: Value(workspace.gradientEndHex),
      shortcut: Value(workspace.shortcut),
      layoutId: Value(workspace.layoutId),
      isActive: Value(workspace.isActive),
      sortOrder: Value(workspace.sortOrder),
    );
  }

  static WorkspaceAppsCompanion toAppCompanion(
    WorkspaceApp app,
    int workspaceId,
    int sortOrder,
  ) {
    return WorkspaceAppsCompanion(
      workspaceId: Value(workspaceId),
      bundleId: Value(app.bundleId),
      appName: Value(app.appName),
      sortOrder: Value(sortOrder),
    );
  }
}
