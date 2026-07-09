import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/services/database/app_database.dart';

/// Persistência das últimas posições de janela por app + configuração
/// de monitores.
abstract interface class WindowPositionsLocalDatasource {
  Future<void> upsert({
    required String bundleId,
    required String monitorFingerprint,
    required double x,
    required double y,
    required double width,
    required double height,
  });

  Future<WindowPositionRow?> find({
    required String bundleId,
    required String monitorFingerprint,
  });
}

@LazySingleton(as: WindowPositionsLocalDatasource)
class WindowPositionsLocalDatasourceImpl
    implements WindowPositionsLocalDatasource {
  const WindowPositionsLocalDatasourceImpl(this._db);

  final AppDatabase _db;

  @override
  Future<void> upsert({
    required String bundleId,
    required String monitorFingerprint,
    required double x,
    required double y,
    required double width,
    required double height,
  }) async {
    try {
      final existing = await find(
        bundleId: bundleId,
        monitorFingerprint: monitorFingerprint,
      );

      final companion = WindowPositionsCompanion(
        id: existing != null ? Value(existing.id) : const Value.absent(),
        bundleId: Value(bundleId),
        monitorFingerprint: Value(monitorFingerprint),
        x: Value(x),
        y: Value(y),
        width: Value(width),
        height: Value(height),
        updatedAt: Value(DateTime.now()),
      );
      await _db.into(_db.windowPositions).insertOnConflictUpdate(companion);
    } catch (e) {
      throw DatabaseException('Falha ao salvar posição de janela: $e');
    }
  }

  @override
  Future<WindowPositionRow?> find({
    required String bundleId,
    required String monitorFingerprint,
  }) async {
    try {
      return await (_db.select(_db.windowPositions)
            ..where(
              (t) =>
                  t.bundleId.equals(bundleId) &
                  t.monitorFingerprint.equals(monitorFingerprint),
            ))
          .getSingleOrNull();
    } catch (e) {
      throw DatabaseException('Falha ao consultar posição de janela: $e');
    }
  }
}
