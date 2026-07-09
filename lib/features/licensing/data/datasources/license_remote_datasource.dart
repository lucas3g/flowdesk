import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';

/// Resposta bruta da API de licenças: payload assinado + assinatura.
class SignedEntitlementDto {
  const SignedEntitlementDto({
    required this.payloadBase64,
    required this.signatureBase64,
  });

  final String payloadBase64;
  final String signatureBase64;
}

/// Cliente da API de licenças (worker em `backend/paddle-licenses`).
abstract interface class LicenseRemoteDatasource {
  Future<SignedEntitlementDto> activate({
    required String key,
    required String deviceId,
  });

  Future<SignedEntitlementDto> validate({
    required String key,
    required String deviceId,
  });

  Future<void> deactivate({required String key, required String deviceId});
}

@LazySingleton(as: LicenseRemoteDatasource)
class LicenseRemoteDatasourceImpl implements LicenseRemoteDatasource {
  const LicenseRemoteDatasourceImpl(this._client);

  final http.Client _client;

  static const _timeout = Duration(seconds: 15);

  @override
  Future<SignedEntitlementDto> activate({
    required String key,
    required String deviceId,
  }) {
    return _postEntitlement('/v1/licenses/activate', {
      'key': key,
      'deviceId': deviceId,
      'deviceName': Platform.localHostname,
      'platform': Platform.operatingSystem,
    });
  }

  @override
  Future<SignedEntitlementDto> validate({
    required String key,
    required String deviceId,
  }) {
    return _postEntitlement('/v1/licenses/validate', {
      'key': key,
      'deviceId': deviceId,
    });
  }

  @override
  Future<void> deactivate({
    required String key,
    required String deviceId,
  }) async {
    await _post('/v1/licenses/deactivate', {'key': key, 'deviceId': deviceId});
  }

  Future<SignedEntitlementDto> _postEntitlement(
    String path,
    Map<String, dynamic> body,
  ) async {
    final json = await _post(path, body);
    final payload = json['payload'];
    final signature = json['signature'];
    if (payload is! String || signature is! String) {
      throw const NetworkException('Resposta inválida da API de licenças');
    }
    return SignedEntitlementDto(
      payloadBase64: payload,
      signatureBase64: signature,
    );
  }

  Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> body,
  ) async {
    final uri = Uri.parse('${AppConstants.licenseApiBaseUrl}$path');
    late final http.Response response;
    try {
      response = await _client
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(_timeout);
    } catch (e) {
      throw NetworkException('Sem conexão com o servidor de licenças: $e');
    }

    final decoded = response.body.isEmpty
        ? const <String, dynamic>{}
        : jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200) {
      throw NetworkException(
        (decoded['error'] as String?) ??
            'Erro ${response.statusCode} na API de licenças',
        statusCode: response.statusCode,
      );
    }
    return decoded;
  }
}
