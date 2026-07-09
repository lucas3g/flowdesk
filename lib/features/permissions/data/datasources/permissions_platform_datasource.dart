import 'package:injectable/injectable.dart';

import '../../../../core/platform/platform_channel.dart';

/// Acesso ao PermissionManager (Swift) via MethodChannel.
abstract interface class PermissionsPlatformDatasource {
  Future<Map<String, dynamic>> getStatus();

  Future<bool> requestAccessibility();

  Future<void> openSystemSettings(String section);
}

@LazySingleton(as: PermissionsPlatformDatasource)
class PermissionsPlatformDatasourceImpl
    implements PermissionsPlatformDatasource {
  const PermissionsPlatformDatasourceImpl(
    @Named('permissionsChannel') this._channel,
  );

  final PlatformChannel _channel;

  @override
  Future<Map<String, dynamic>> getStatus() => _channel.invokeMap('getStatus');

  @override
  Future<bool> requestAccessibility() async {
    return await _channel.invoke<bool>('requestAccessibility') ?? false;
  }

  @override
  Future<void> openSystemSettings(String section) {
    return _channel.invoke<void>('openSystemSettings', {'section': section});
  }
}
