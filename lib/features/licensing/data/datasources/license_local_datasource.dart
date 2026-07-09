import 'dart:math';

import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/services/database/app_database.dart';

/// Acesso à linha única da licença no banco local.
abstract interface class LicenseLocalDatasource {
  /// Linha atual, materializada com um deviceId novo na primeira consulta.
  Future<LicenseRow> getLicenseRow();

  /// Grava o entitlement recebido do servidor.
  Future<void> saveEntitlement({
    required String licenseKey,
    required String payloadBase64,
    required String signatureBase64,
    required DateTime validatedAt,
  });

  /// Remove a licença, preservando o deviceId da instalação.
  Future<void> clearEntitlement();
}

@LazySingleton(as: LicenseLocalDatasource)
class LicenseLocalDatasourceImpl implements LicenseLocalDatasource {
  const LicenseLocalDatasourceImpl(this._db);

  final AppDatabase _db;

  @override
  Future<LicenseRow> getLicenseRow() async {
    try {
      final existing = await _db.select(_db.licenseTable).getSingleOrNull();
      if (existing != null) return existing;

      await _db
          .into(_db.licenseTable)
          .insert(
            LicenseTableCompanion.insert(
              id: const Value(0),
              deviceId: _newDeviceId(),
            ),
          );
      return _db.select(_db.licenseTable).getSingle();
    } catch (e) {
      throw DatabaseException('Falha ao carregar a licença: $e');
    }
  }

  @override
  Future<void> saveEntitlement({
    required String licenseKey,
    required String payloadBase64,
    required String signatureBase64,
    required DateTime validatedAt,
  }) async {
    try {
      final row = await getLicenseRow();
      await _db
          .into(_db.licenseTable)
          .insertOnConflictUpdate(
            LicenseTableCompanion(
              id: const Value(0),
              deviceId: Value(row.deviceId),
              licenseKey: Value(licenseKey),
              entitlementPayload: Value(payloadBase64),
              entitlementSignature: Value(signatureBase64),
              lastValidatedAt: Value(validatedAt),
            ),
          );
    } catch (e) {
      throw DatabaseException('Falha ao salvar a licença: $e');
    }
  }

  @override
  Future<void> clearEntitlement() async {
    try {
      final row = await getLicenseRow();
      await _db
          .into(_db.licenseTable)
          .insertOnConflictUpdate(
            LicenseTableCompanion(
              id: const Value(0),
              deviceId: Value(row.deviceId),
              licenseKey: const Value(''),
              entitlementPayload: const Value(''),
              entitlementSignature: const Value(''),
              lastValidatedAt: const Value(null),
            ),
          );
    } catch (e) {
      throw DatabaseException('Falha ao remover a licença: $e');
    }
  }

  /// Identificador aleatório e estável da instalação (32 hex chars).
  String _newDeviceId() {
    final random = Random.secure();
    return List.generate(
      32,
      (_) => random.nextInt(16).toRadixString(16),
    ).join();
  }
}
