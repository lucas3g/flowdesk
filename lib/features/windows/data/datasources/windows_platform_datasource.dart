import 'package:injectable/injectable.dart';

import '../../../../core/platform/platform_channel.dart';

/// Acesso ao WindowManager (Swift) via MethodChannel.
abstract interface class WindowsPlatformDatasource {
  Future<Object?> getWindows();

  Future<bool> setWindowFrame({
    required int windowId,
    required int pid,
    required double x,
    required double y,
    required double width,
    required double height,
  });

  Future<bool> focusWindow({required int windowId, required int pid});
}

@LazySingleton(as: WindowsPlatformDatasource)
class WindowsPlatformDatasourceImpl implements WindowsPlatformDatasource {
  const WindowsPlatformDatasourceImpl(@Named('windowsChannel') this._channel);

  final PlatformChannel _channel;

  @override
  Future<Object?> getWindows() => _channel.invoke<Object?>('getWindows');

  @override
  Future<bool> setWindowFrame({
    required int windowId,
    required int pid,
    required double x,
    required double y,
    required double width,
    required double height,
  }) async {
    final success = await _channel.invoke<bool>('setWindowFrame', {
      'id': windowId,
      'pid': pid,
      'x': x,
      'y': y,
      'width': width,
      'height': height,
    });
    return success ?? false;
  }

  @override
  Future<bool> focusWindow({required int windowId, required int pid}) async {
    final success = await _channel.invoke<bool>('focusWindow', {
      'id': windowId,
      'pid': pid,
    });
    return success ?? false;
  }
}
