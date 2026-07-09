import 'package:flutter/services.dart';

import '../errors/exceptions.dart';

/// Wrapper fino sobre [EventChannel] usado pelas datasources de plataforma.
///
/// Converte erros do canal em [PlatformDatasourceException], mantendo a
/// camada de dados desacoplada do Flutter services.
class PlatformEventChannel {
  PlatformEventChannel(String name) : _channel = EventChannel(name);

  /// Permite injetar um canal customizado em testes.
  PlatformEventChannel.withChannel(this._channel);

  final EventChannel _channel;

  Stream<T> receive<T>() {
    return _channel.receiveBroadcastStream().handleError((Object error) {
      if (error is PlatformException) {
        throw PlatformDatasourceException(
          error.message ?? 'Erro no stream nativo (${_channel.name})',
          code: error.code,
        );
      }
      throw PlatformDatasourceException('$error');
    }).cast<T>();
  }
}
