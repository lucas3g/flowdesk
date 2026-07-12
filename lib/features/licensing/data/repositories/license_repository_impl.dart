import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/license.dart';
import '../../domain/repositories/license_repository.dart';
import '../datasources/license_local_datasource.dart';
import '../datasources/license_remote_datasource.dart';
import '../services/entitlement_verifier.dart';

@LazySingleton(as: LicenseRepository)
class LicenseRepositoryImpl implements LicenseRepository {
  const LicenseRepositoryImpl(this._local, this._remote, this._verifier);

  final LicenseLocalDatasource _local;
  final LicenseRemoteDatasource _remote;
  final EntitlementVerifier _verifier;

  @override
  Future<Either<Failure, License>> getLicense() async {
    try {
      final row = await _local.getLicenseRow();
      if (row.entitlementPayload.isEmpty) return right(License.free);

      final entitlement = await _verifier.verify(
        payloadBase64: row.entitlementPayload,
        signatureBase64: row.entitlementSignature,
      );
      // Assinatura inválida ou payload adulterado: trata como plano grátis.
      if (entitlement == null || entitlement.deviceId != row.deviceId) {
        return right(License.free);
      }

      return right(_toLicense(entitlement, row.lastValidatedAt));
    } on DatabaseException catch (e) {
      return left(DatabaseFailure(e.message));
    } catch (e) {
      return left(UnexpectedFailure('$e'));
    }
  }

  @override
  Future<Either<Failure, License>> activate(String key) async {
    try {
      final row = await _local.getLicenseRow();
      final dto = await _remote.activate(key: key, deviceId: row.deviceId);
      return _storeAndBuild(key, row.deviceId, dto);
    } on NetworkException catch (e) {
      return left(NetworkFailure(e.message, statusCode: e.statusCode));
    } on DatabaseException catch (e) {
      return left(DatabaseFailure(e.message));
    } catch (e) {
      return left(UnexpectedFailure('$e'));
    }
  }

  @override
  Future<Either<Failure, License>> refresh() async {
    try {
      final row = await _local.getLicenseRow();
      if (row.licenseKey.isEmpty) return right(License.free);

      final dto = await _remote.validate(
        key: row.licenseKey,
        deviceId: row.deviceId,
      );
      return _storeAndBuild(row.licenseKey, row.deviceId, dto);
    } on NetworkException catch (e) {
      // Servidor negou a licença (revogada/cancelada): remove o cache.
      // Falha de conectividade mantém o cache e a tolerância offline.
      if (e.statusCode != null) {
        await _local.clearEntitlement();
        return right(License.free);
      }
      return left(NetworkFailure(e.message));
    } on DatabaseException catch (e) {
      return left(DatabaseFailure(e.message));
    } catch (e) {
      return left(UnexpectedFailure('$e'));
    }
  }

  @override
  Future<Either<Failure, License>> deactivate() async {
    try {
      final row = await _local.getLicenseRow();
      if (row.licenseKey.isNotEmpty) {
        try {
          await _remote.deactivate(key: row.licenseKey, deviceId: row.deviceId);
        } on NetworkException {
          // Sem rede o seat fica pendente no servidor, mas a instalação
          // local volta ao plano grátis mesmo assim.
        }
      }
      await _local.clearEntitlement();
      return right(License.free);
    } on DatabaseException catch (e) {
      return left(DatabaseFailure(e.message));
    } catch (e) {
      return left(UnexpectedFailure('$e'));
    }
  }

  Future<Either<Failure, License>> _storeAndBuild(
    String key,
    String deviceId,
    SignedEntitlementDto dto,
  ) async {
    final entitlement = await _verifier.verify(
      payloadBase64: dto.payloadBase64,
      signatureBase64: dto.signatureBase64,
    );
    if (entitlement == null || entitlement.deviceId != deviceId) {
      return left(
        const ValidationFailure('Entitlement recebido do servidor é inválido'),
      );
    }

    final now = DateTime.now();
    await _local.saveEntitlement(
      licenseKey: key,
      payloadBase64: dto.payloadBase64,
      signatureBase64: dto.signatureBase64,
      validatedAt: now,
    );
    return right(_toLicense(entitlement, now));
  }

  /// Plano efetivo: premium até `premiumUntil` e, depois disso, apenas
  /// durante a tolerância offline de [AppConstants.licenseGraceDays].
  License _toLicense(Entitlement entitlement, DateTime? lastValidatedAt) {
    final now = DateTime.now();
    final premiumUntil = entitlement.premiumUntil;
    final graceLimit = premiumUntil.add(
      const Duration(days: AppConstants.licenseGraceDays),
    );

    final withinPaid = now.isBefore(premiumUntil);
    final withinGrace = !withinPaid && now.isBefore(graceLimit);

    if (entitlement.plan != 'premium' || (!withinPaid && !withinGrace)) {
      return License(
        plan: LicensePlan.free,
        key: entitlement.key,
        premiumUntil: premiumUntil,
        lastValidatedAt: lastValidatedAt,
      );
    }

    return License(
      plan: LicensePlan.premium,
      key: entitlement.key,
      premiumUntil: premiumUntil,
      lastValidatedAt: lastValidatedAt,
      inGracePeriod: withinGrace,
    );
  }
}
