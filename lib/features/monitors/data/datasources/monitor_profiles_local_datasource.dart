import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/services/database/app_database.dart';
import '../../domain/entities/monitor_profile.dart';

/// Persistência dos perfis de monitores no banco local.
abstract interface class MonitorProfilesLocalDatasource {
  Future<List<MonitorProfile>> getProfiles();

  Future<MonitorProfile> saveProfile(MonitorProfile profile);

  Future<void> deleteProfile(int profileId);
}

@LazySingleton(as: MonitorProfilesLocalDatasource)
class MonitorProfilesLocalDatasourceImpl
    implements MonitorProfilesLocalDatasource {
  const MonitorProfilesLocalDatasourceImpl(this._db);

  final AppDatabase _db;

  @override
  Future<List<MonitorProfile>> getProfiles() async {
    try {
      final rows = await _db.select(_db.monitorProfiles).get();
      return [
        for (final row in rows)
          MonitorProfile(
            id: row.id,
            name: row.name,
            fingerprint: row.fingerprint,
            workspaceId: row.workspaceId,
            layoutId: row.layoutId,
            autoApply: row.autoApply,
          ),
      ];
    } catch (e) {
      throw DatabaseException('Falha ao carregar perfis: $e');
    }
  }

  @override
  Future<MonitorProfile> saveProfile(MonitorProfile profile) async {
    try {
      // Fingerprint é único: substitui o perfil existente da mesma
      // configuração de monitores.
      final existing =
          await (_db.select(_db.monitorProfiles)
                ..where((t) => t.fingerprint.equals(profile.fingerprint)))
              .getSingleOrNull();

      final companion = MonitorProfilesCompanion(
        id: existing != null
            ? Value(existing.id)
            : (profile.id == 0 ? const Value.absent() : Value(profile.id)),
        name: Value(profile.name),
        fingerprint: Value(profile.fingerprint),
        workspaceId: Value(profile.workspaceId),
        layoutId: Value(profile.layoutId),
        autoApply: Value(profile.autoApply),
      );

      final id = await _db
          .into(_db.monitorProfiles)
          .insertOnConflictUpdate(companion);
      return profile.copyWith(id: existing?.id ?? id);
    } catch (e) {
      throw DatabaseException('Falha ao salvar perfil: $e');
    }
  }

  @override
  Future<void> deleteProfile(int profileId) async {
    try {
      await (_db.delete(
        _db.monitorProfiles,
      )..where((t) => t.id.equals(profileId))).go();
    } catch (e) {
      throw DatabaseException('Falha ao excluir perfil: $e');
    }
  }
}
