import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/services/database/app_database.dart';
import '../../domain/entities/layout.dart';
import '../models/layout_mapper.dart';
import 'preset_layouts.dart';

/// Persistência de layouts no banco local.
abstract interface class LayoutsLocalDatasource {
  Future<List<Layout>> getLayouts();

  Future<Layout> saveLayout(Layout layout);

  Future<void> deleteLayout(int layoutId);

  Future<void> setFavorite(int layoutId, bool isFavorite);

  /// Layout aplicado em cada monitor (chave estável → id do layout).
  Future<Map<String, int>> getAppliedLayouts();

  Future<void> setAppliedLayout(String monitorKey, int layoutId);

  Future<void> removeAppliedLayout(String monitorKey);
}

@LazySingleton(as: LayoutsLocalDatasource)
class LayoutsLocalDatasourceImpl implements LayoutsLocalDatasource {
  const LayoutsLocalDatasourceImpl(this._db);

  final AppDatabase _db;

  @override
  Future<List<Layout>> getLayouts() async {
    try {
      await _seedPresetsIfEmpty();

      final layoutRows = await (_db.select(
        _db.layouts,
      )..orderBy([(t) => OrderingTerm.asc(t.id)])).get();
      final regionRows = await _db.select(_db.layoutRegions).get();

      final regionsByLayout = <int, List<LayoutRegionRow>>{};
      for (final region in regionRows) {
        regionsByLayout.putIfAbsent(region.layoutId, () => []).add(region);
      }

      return [
        for (final layout in layoutRows)
          LayoutMapper.fromRows(layout, regionsByLayout[layout.id] ?? const []),
      ];
    } catch (e) {
      throw DatabaseException('Falha ao carregar layouts: $e');
    }
  }

  @override
  Future<Layout> saveLayout(Layout layout) async {
    try {
      return await _db.transaction(() async {
        final int layoutId;
        if (layout.id == 0) {
          layoutId = await _db
              .into(_db.layouts)
              .insert(LayoutMapper.toLayoutCompanion(layout));
        } else {
          layoutId = layout.id;
          await (_db.update(_db.layouts)..where((t) => t.id.equals(layoutId)))
              .write(LayoutMapper.toLayoutCompanion(layout));
          // Regravar as regiões é mais simples e seguro do que reconciliar.
          await (_db.delete(
            _db.layoutRegions,
          )..where((t) => t.layoutId.equals(layoutId))).go();
        }

        for (var i = 0; i < layout.regions.length; i++) {
          await _db
              .into(_db.layoutRegions)
              .insert(
                LayoutMapper.toRegionCompanion(layout.regions[i], layoutId, i),
              );
        }

        return _loadLayout(layoutId);
      });
    } catch (e) {
      throw DatabaseException('Falha ao salvar layout: $e');
    }
  }

  @override
  Future<void> deleteLayout(int layoutId) async {
    try {
      await (_db.delete(_db.layouts)..where((t) => t.id.equals(layoutId))).go();
    } catch (e) {
      throw DatabaseException('Falha ao excluir layout: $e');
    }
  }

  @override
  Future<void> setFavorite(int layoutId, bool isFavorite) async {
    try {
      await (_db.update(_db.layouts)..where((t) => t.id.equals(layoutId)))
          .write(LayoutsCompanion(isFavorite: Value(isFavorite)));
    } catch (e) {
      throw DatabaseException('Falha ao favoritar layout: $e');
    }
  }

  @override
  Future<Map<String, int>> getAppliedLayouts() async {
    try {
      final rows = await _db.select(_db.appliedLayouts).get();
      return {for (final row in rows) row.monitorKey: row.layoutId};
    } catch (e) {
      throw DatabaseException('Falha ao carregar layouts aplicados: $e');
    }
  }

  @override
  Future<void> setAppliedLayout(String monitorKey, int layoutId) async {
    try {
      await _db
          .into(_db.appliedLayouts)
          .insertOnConflictUpdate(
            AppliedLayoutsCompanion.insert(
              monitorKey: monitorKey,
              layoutId: layoutId,
            ),
          );
    } catch (e) {
      throw DatabaseException('Falha ao salvar layout aplicado: $e');
    }
  }

  @override
  Future<void> removeAppliedLayout(String monitorKey) async {
    try {
      await (_db.delete(
        _db.appliedLayouts,
      )..where((t) => t.monitorKey.equals(monitorKey))).go();
    } catch (e) {
      throw DatabaseException('Falha ao remover layout aplicado: $e');
    }
  }

  Future<Layout> _loadLayout(int layoutId) async {
    final layoutRow = await (_db.select(
      _db.layouts,
    )..where((t) => t.id.equals(layoutId))).getSingle();
    final regionRows = await (_db.select(
      _db.layoutRegions,
    )..where((t) => t.layoutId.equals(layoutId))).get();
    return LayoutMapper.fromRows(layoutRow, regionRows);
  }

  Future<void> _seedPresetsIfEmpty() async {
    final existing = await _db.select(_db.layouts).get();
    if (existing.isNotEmpty) return;

    for (final preset in presetLayouts) {
      await saveLayout(preset);
    }
  }
}
