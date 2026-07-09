import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:flowdesk/core/errors/exceptions.dart';
import 'package:flowdesk/core/errors/failures.dart';
import 'package:flowdesk/core/services/database/app_database.dart';
import 'package:flowdesk/features/licensing/data/datasources/license_local_datasource.dart';
import 'package:flowdesk/features/licensing/data/datasources/license_remote_datasource.dart';
import 'package:flowdesk/features/licensing/data/repositories/license_repository_impl.dart';
import 'package:flowdesk/features/licensing/data/services/entitlement_verifier.dart';
import 'package:flowdesk/features/licensing/domain/entities/license.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRemoteDatasource extends Mock implements LicenseRemoteDatasource {}

/// Datasource local em memória — evita subir banco Drift no teste.
class _FakeLocalDatasource implements LicenseLocalDatasource {
  LicenseRow row = LicenseRow(
    id: 0,
    deviceId: 'device-1',
    licenseKey: '',
    entitlementPayload: '',
    entitlementSignature: '',
    lastValidatedAt: null,
  );

  @override
  Future<LicenseRow> getLicenseRow() async => row;

  @override
  Future<void> saveEntitlement({
    required String licenseKey,
    required String payloadBase64,
    required String signatureBase64,
    required DateTime validatedAt,
  }) async {
    row = LicenseRow(
      id: 0,
      deviceId: row.deviceId,
      licenseKey: licenseKey,
      entitlementPayload: payloadBase64,
      entitlementSignature: signatureBase64,
      lastValidatedAt: validatedAt,
    );
  }

  @override
  Future<void> clearEntitlement() async {
    row = LicenseRow(
      id: 0,
      deviceId: row.deviceId,
      licenseKey: '',
      entitlementPayload: '',
      entitlementSignature: '',
      lastValidatedAt: null,
    );
  }
}

void main() {
  late SimpleKeyPair keyPair;
  late EntitlementVerifier verifier;
  late _FakeLocalDatasource local;
  late _MockRemoteDatasource remote;
  late LicenseRepositoryImpl repository;

  /// Assina um entitlement como o backend faria.
  Future<SignedEntitlementDto> signedEntitlement({
    String key = 'FD-TESTE-1234',
    String plan = 'premium',
    String deviceId = 'device-1',
    required DateTime premiumUntil,
  }) async {
    final payload = utf8.encode(
      jsonEncode({
        'key': key,
        'plan': plan,
        'deviceId': deviceId,
        'premiumUntil': premiumUntil.toUtc().toIso8601String(),
        'issuedAt': DateTime.now().toUtc().toIso8601String(),
      }),
    );
    final signature = await Ed25519().sign(payload, keyPair: keyPair);
    return SignedEntitlementDto(
      payloadBase64: base64Encode(payload),
      signatureBase64: base64Encode(signature.bytes),
    );
  }

  setUpAll(() async {
    keyPair = await Ed25519().newKeyPair();
    final publicKey = await keyPair.extractPublicKey();
    verifier = EntitlementVerifier.withPublicKey(
      base64Encode(publicKey.bytes),
    );
  });

  setUp(() {
    local = _FakeLocalDatasource();
    remote = _MockRemoteDatasource();
    repository = LicenseRepositoryImpl(local, remote, verifier);
  });

  group('getLicense', () {
    test('retorna plano grátis quando nunca houve ativação', () async {
      final result = await repository.getLicense();

      expect(result.toNullable(), License.free);
    });

    test('retorna premium com entitlement válido e vigente', () async {
      final dto = await signedEntitlement(
        premiumUntil: DateTime.now().add(const Duration(days: 30)),
      );
      await local.saveEntitlement(
        licenseKey: 'FD-TESTE-1234',
        payloadBase64: dto.payloadBase64,
        signatureBase64: dto.signatureBase64,
        validatedAt: DateTime.now(),
      );

      final result = await repository.getLicense();

      final license = result.toNullable()!;
      expect(license.plan, LicensePlan.premium);
      expect(license.inGracePeriod, isFalse);
    });

    test('payload adulterado no banco vira plano grátis', () async {
      final dto = await signedEntitlement(
        premiumUntil: DateTime.now().add(const Duration(days: 30)),
      );
      final tampered = base64Encode(
        utf8.encode(
          utf8
              .decode(base64Decode(dto.payloadBase64))
              .replaceAll('premium', 'premium2'),
        ),
      );
      await local.saveEntitlement(
        licenseKey: 'FD-TESTE-1234',
        payloadBase64: tampered,
        signatureBase64: dto.signatureBase64,
        validatedAt: DateTime.now(),
      );

      final result = await repository.getLicense();

      expect(result.toNullable()!.plan, LicensePlan.free);
    });

    test('premium vencido dentro da tolerância continua ativo', () async {
      final dto = await signedEntitlement(
        premiumUntil: DateTime.now().subtract(const Duration(days: 2)),
      );
      await local.saveEntitlement(
        licenseKey: 'FD-TESTE-1234',
        payloadBase64: dto.payloadBase64,
        signatureBase64: dto.signatureBase64,
        validatedAt: DateTime.now(),
      );

      final result = await repository.getLicense();

      final license = result.toNullable()!;
      expect(license.plan, LicensePlan.premium);
      expect(license.inGracePeriod, isTrue);
    });

    test('premium vencido além da tolerância vira plano grátis', () async {
      final dto = await signedEntitlement(
        premiumUntil: DateTime.now().subtract(const Duration(days: 30)),
      );
      await local.saveEntitlement(
        licenseKey: 'FD-TESTE-1234',
        payloadBase64: dto.payloadBase64,
        signatureBase64: dto.signatureBase64,
        validatedAt: DateTime.now(),
      );

      final result = await repository.getLicense();

      expect(result.toNullable()!.plan, LicensePlan.free);
    });
  });

  group('activate', () {
    test('persiste o entitlement e retorna premium', () async {
      final dto = await signedEntitlement(
        premiumUntil: DateTime.now().add(const Duration(days: 30)),
      );
      when(
        () => remote.activate(key: 'FD-TESTE-1234', deviceId: 'device-1'),
      ).thenAnswer((_) async => dto);

      final result = await repository.activate('FD-TESTE-1234');

      expect(result.toNullable()!.plan, LicensePlan.premium);
      expect(local.row.licenseKey, 'FD-TESTE-1234');
      expect(local.row.entitlementPayload, dto.payloadBase64);
    });

    test('entitlement de outro deviceId é rejeitado', () async {
      final dto = await signedEntitlement(
        deviceId: 'device-de-outra-maquina',
        premiumUntil: DateTime.now().add(const Duration(days: 30)),
      );
      when(
        () => remote.activate(key: 'FD-TESTE-1234', deviceId: 'device-1'),
      ).thenAnswer((_) async => dto);

      final result = await repository.activate('FD-TESTE-1234');

      expect(result.getLeft().toNullable(), isA<ValidationFailure>());
    });

    test('erro de rede vira NetworkFailure', () async {
      when(
        () => remote.activate(key: 'FD-TESTE-1234', deviceId: 'device-1'),
      ).thenThrow(const NetworkException('Chave não encontrada', statusCode: 404));

      final result = await repository.activate('FD-TESTE-1234');

      expect(result.getLeft().toNullable(), isA<NetworkFailure>());
    });
  });

  group('refresh', () {
    setUp(() async {
      final dto = await signedEntitlement(
        premiumUntil: DateTime.now().add(const Duration(days: 1)),
      );
      await local.saveEntitlement(
        licenseKey: 'FD-TESTE-1234',
        payloadBase64: dto.payloadBase64,
        signatureBase64: dto.signatureBase64,
        validatedAt: DateTime.now(),
      );
    });

    test('licença revogada pelo servidor limpa o cache local', () async {
      when(
        () => remote.validate(key: 'FD-TESTE-1234', deviceId: 'device-1'),
      ).thenThrow(const NetworkException('Assinatura cancelada', statusCode: 410));

      final result = await repository.refresh();

      expect(result.toNullable(), License.free);
      expect(local.row.entitlementPayload, isEmpty);
    });

    test('falha de conectividade preserva o cache local', () async {
      when(
        () => remote.validate(key: 'FD-TESTE-1234', deviceId: 'device-1'),
      ).thenThrow(const NetworkException('Sem conexão'));

      final result = await repository.refresh();

      expect(result.getLeft().toNullable(), isA<NetworkFailure>());
      expect(local.row.entitlementPayload, isNotEmpty);
    });
  });

  group('deactivate', () {
    test('limpa o cache mesmo sem conseguir avisar o servidor', () async {
      final dto = await signedEntitlement(
        premiumUntil: DateTime.now().add(const Duration(days: 30)),
      );
      await local.saveEntitlement(
        licenseKey: 'FD-TESTE-1234',
        payloadBase64: dto.payloadBase64,
        signatureBase64: dto.signatureBase64,
        validatedAt: DateTime.now(),
      );
      when(
        () => remote.deactivate(key: 'FD-TESTE-1234', deviceId: 'device-1'),
      ).thenThrow(const NetworkException('Sem conexão'));

      final result = await repository.deactivate();

      expect(result.toNullable(), License.free);
      expect(local.row.entitlementPayload, isEmpty);
    });
  });
}
