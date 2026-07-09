import 'package:flutter/services.dart';

import '../errors/exceptions.dart';

/// Wrapper fino sobre [MethodChannel] usado pelas datasources de plataforma.
///
/// Converte [PlatformException]/[MissingPluginException] em
/// [PlatformDatasourceException] para que a camada de dados não dependa
/// de tipos do Flutter services.
class PlatformChannel {
  PlatformChannel(String name) : _channel = MethodChannel(name);

  /// Permite injetar um canal customizado em testes.
  PlatformChannel.withChannel(this._channel);

  final MethodChannel _channel;

  Future<T?> invoke<T>(String method, [Object? arguments]) async {
    try {
      return await _channel.invokeMethod<T>(method, arguments);
    } on PlatformException catch (e) {
      throw PlatformDatasourceException(
        e.message ?? 'Erro na camada nativa ($method)',
        code: e.code,
      );
    } on MissingPluginException {
      throw PlatformDatasourceException(
        'Canal ${_channel.name} não registrado no macOS ($method)',
      );
    }
  }

  /// Invoca um método que retorna um mapa (payload típico dos managers Swift).
  Future<Map<String, dynamic>> invokeMap(
    String method, [
    Object? arguments,
  ]) async {
    final result = await invoke<Map<Object?, Object?>>(method, arguments);
    return result?.map((key, value) => MapEntry('$key', value)) ?? {};
  }
}
