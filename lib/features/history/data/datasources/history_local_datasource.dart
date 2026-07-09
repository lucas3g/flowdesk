import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/services/database/app_database.dart';
import '../../domain/entities/history_entry.dart';

/// Persistência do histórico no banco local.
abstract interface class HistoryLocalDatasource {
  Future<List<HistoryEntry>> getEntries({int limit});

  Future<void> addEntry(HistoryEntry entry);

  Future<void> clear();
}

@LazySingleton(as: HistoryLocalDatasource)
class HistoryLocalDatasourceImpl implements HistoryLocalDatasource {
  const HistoryLocalDatasourceImpl(this._db);

  final AppDatabase _db;

  @override
  Future<List<HistoryEntry>> getEntries({int limit = 50}) async {
    try {
      final rows =
          await (_db.select(_db.historyEntries)
                ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
                ..limit(limit))
              .get();
      return [
        for (final row in rows)
          HistoryEntry(
            id: row.id,
            type: HistoryEntryType.fromName(row.type),
            title: row.title,
            subtitle: row.subtitle,
            createdAt: row.createdAt,
          ),
      ];
    } catch (e) {
      throw DatabaseException('Falha ao carregar histórico: $e');
    }
  }

  @override
  Future<void> addEntry(HistoryEntry entry) async {
    try {
      await _db
          .into(_db.historyEntries)
          .insert(
            HistoryEntriesCompanion(
              type: Value(entry.type.name),
              title: Value(entry.title),
              subtitle: Value(entry.subtitle),
              createdAt: Value(entry.createdAt),
            ),
          );
    } catch (e) {
      throw DatabaseException('Falha ao registrar histórico: $e');
    }
  }

  @override
  Future<void> clear() async {
    try {
      await _db.delete(_db.historyEntries).go();
    } catch (e) {
      throw DatabaseException('Falha ao limpar histórico: $e');
    }
  }
}
