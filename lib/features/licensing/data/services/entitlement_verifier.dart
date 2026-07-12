import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/constants/app_constants.dart';

/// Conteúdo de um entitlement emitido pela API de licenças.
class Entitlement {
  const Entitlement({
    required this.key,
    required this.plan,
    required this.deviceId,
    required this.premiumUntil,
    required this.issuedAt,
  });

  final String key;
  final String plan;
  final String deviceId;
  final DateTime premiumUntil;
  final DateTime issuedAt;
}

/// Verifica a assinatura Ed25519 do entitlement e decodifica o payload.
///
/// O payload viaja e é armazenado em base64 exatamente como assinado pelo
/// servidor — qualquer alteração local invalida a assinatura.
@lazySingleton
class EntitlementVerifier {
  EntitlementVerifier()
    : _publicKeyBase64 = AppConstants.licensePublicKeyBase64;

  /// Permite injetar outra chave pública em testes.
  EntitlementVerifier.withPublicKey(this._publicKeyBase64);

  final String _publicKeyBase64;
  final Ed25519 _algorithm = Ed25519();

  /// Retorna o entitlement decodificado se a assinatura for válida e o
  /// payload bem formado; caso contrário, null.
  Future<Entitlement?> verify({
    required String payloadBase64,
    required String signatureBase64,
  }) async {
    try {
      final payloadBytes = base64Decode(payloadBase64);
      final signature = Signature(
        base64Decode(signatureBase64),
        publicKey: SimplePublicKey(
          base64Decode(_publicKeyBase64),
          type: KeyPairType.ed25519,
        ),
      );

      final valid = await _algorithm.verify(payloadBytes, signature: signature);
      if (!valid) return null;

      final json =
          jsonDecode(utf8.decode(payloadBytes)) as Map<String, dynamic>;
      return Entitlement(
        key: json['key'] as String,
        plan: json['plan'] as String,
        deviceId: json['deviceId'] as String,
        premiumUntil: DateTime.parse(json['premiumUntil'] as String),
        issuedAt: DateTime.parse(json['issuedAt'] as String),
      );
    } catch (_) {
      return null;
    }
  }
}
