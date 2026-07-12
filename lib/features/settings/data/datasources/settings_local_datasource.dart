import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/services/database/app_database.dart';

/// Acesso à linha única de preferências no banco local.
abstract interface class SettingsLocalDatasource {
  Future<SettingsRow> getSettings();

  Future<void> saveSettings(SettingsTableCompanion companion);
}

@LazySingleton(as: SettingsLocalDatasource)
class SettingsLocalDatasourceImpl implements SettingsLocalDatasource {
  const SettingsLocalDatasourceImpl(this._db);

  final AppDatabase _db;

  @override
  Future<SettingsRow> getSettings() async {
    try {
      final existing = await _db.select(_db.settingsTable).getSingleOrNull();
      if (existing != null) return existing;

      // Primeira execução: materializa a linha com os valores padrão.
      await _db
          .into(_db.settingsTable)
          .insert(const SettingsTableCompanion(id: Value(0)));
      return _db.select(_db.settingsTable).getSingle();
    } catch (e) {
      throw DatabaseException('Falha ao carregar preferências: $e');
    }
  }

  @override
  Future<void> saveSettings(SettingsTableCompanion companion) async {
    try {
      await _db
          .into(_db.settingsTable)
          .insertOnConflictUpdate(companion.copyWith(id: const Value(0)));
    } catch (e) {
      throw DatabaseException('Falha ao salvar preferências: $e');
    }
  }
}
