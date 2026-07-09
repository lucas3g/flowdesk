import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/services/database/app_database.dart';
import '../../domain/entities/workspace.dart';
import '../models/workspace_mapper.dart';
import 'preset_workspaces.dart';

/// Persistência de workspaces no banco local.
abstract interface class WorkspacesLocalDatasource {
  Future<List<Workspace>> getWorkspaces();

  Future<Workspace> saveWorkspace(Workspace workspace);

  Future<void> deleteWorkspace(int workspaceId);

  Future<void> setActive(int workspaceId);
}

@LazySingleton(as: WorkspacesLocalDatasource)
class WorkspacesLocalDatasourceImpl implements WorkspacesLocalDatasource {
  const WorkspacesLocalDatasourceImpl(this._db);

  final AppDatabase _db;

  @override
  Future<List<Workspace>> getWorkspaces() async {
    try {
      await _seedIfEmpty();

      final workspaceRows = await (_db.select(
        _db.workspaces,
      )..orderBy([(t) => OrderingTerm.asc(t.sortOrder)])).get();
      final appRows = await _db.select(_db.workspaceApps).get();

      final appsByWorkspace = <int, List<WorkspaceAppRow>>{};
      for (final app in appRows) {
        appsByWorkspace.putIfAbsent(app.workspaceId, () => []).add(app);
      }

      return [
        for (final row in workspaceRows)
          WorkspaceMapper.fromRows(row, appsByWorkspace[row.id] ?? const []),
      ];
    } catch (e) {
      throw DatabaseException('Falha ao carregar workspaces: $e');
    }
  }

  @override
  Future<Workspace> saveWorkspace(Workspace workspace) async {
    try {
      return await _db.transaction(() async {
        final int workspaceId;
        if (workspace.id == 0) {
          workspaceId = await _db
              .into(_db.workspaces)
              .insert(WorkspaceMapper.toCompanion(workspace));
        } else {
          workspaceId = workspace.id;
          await (_db.update(
            _db.workspaces,
          )..where((t) => t.id.equals(workspaceId))).write(
            WorkspaceMapper.toCompanion(workspace),
          );
          await (_db.delete(
            _db.workspaceApps,
          )..where((t) => t.workspaceId.equals(workspaceId))).go();
        }

        for (var i = 0; i < workspace.apps.length; i++) {
          await _db
              .into(_db.workspaceApps)
              .insert(
                WorkspaceMapper.toAppCompanion(
                  workspace.apps[i],
                  workspaceId,
                  i,
                ),
              );
        }

        final row = await (_db.select(
          _db.workspaces,
        )..where((t) => t.id.equals(workspaceId))).getSingle();
        final apps = await (_db.select(
          _db.workspaceApps,
        )..where((t) => t.workspaceId.equals(workspaceId))).get();
        return WorkspaceMapper.fromRows(row, apps);
      });
    } catch (e) {
      throw DatabaseException('Falha ao salvar workspace: $e');
    }
  }

  @override
  Future<void> deleteWorkspace(int workspaceId) async {
    try {
      await (_db.delete(
        _db.workspaces,
      )..where((t) => t.id.equals(workspaceId))).go();
    } catch (e) {
      throw DatabaseException('Falha ao excluir workspace: $e');
    }
  }

  @override
  Future<void> setActive(int workspaceId) async {
    try {
      await _db.transaction(() async {
        await _db
            .update(_db.workspaces)
            .write(const WorkspacesCompanion(isActive: Value(false)));
        await (_db.update(
          _db.workspaces,
        )..where((t) => t.id.equals(workspaceId))).write(
          const WorkspacesCompanion(isActive: Value(true)),
        );
      });
    } catch (e) {
      throw DatabaseException('Falha ao ativar workspace: $e');
    }
  }

  Future<void> _seedIfEmpty() async {
    final existing = await _db.select(_db.workspaces).get();
    if (existing.isNotEmpty) return;

    // Vincula cada workspace de exemplo ao layout preset pelo nome.
    final layouts = await _db.select(_db.layouts).get();
    int? layoutIdByName(String? name) {
      if (name == null) return null;
      for (final layout in layouts) {
        if (layout.name == name) return layout.id;
      }
      return null;
    }

    for (final preset in presetWorkspaces) {
      await saveWorkspace(
        preset.copyWith(
          layoutId: () =>
              layoutIdByName(presetWorkspaceLayoutNames[preset.name]),
        ),
      );
    }
  }
}
