import 'package:injectable/injectable.dart';

import '../../../../core/platform/platform_channel.dart';

/// Acesso aos managers de sistema (StatusBar/LaunchAtLogin/Snap) via canal
/// `flowdesk/app`.
abstract interface class SystemPlatformDatasource {
  Future<void> setLaunchAtLogin(bool enabled);

  Future<void> setDockVisible(bool visible);

  Future<void> setStatusBarVisible(bool visible);

  Future<void> setMagneticSnap(bool enabled);
}

@LazySingleton(as: SystemPlatformDatasource)
class SystemPlatformDatasourceImpl implements SystemPlatformDatasource {
  const SystemPlatformDatasourceImpl(@Named('appChannel') this._channel);

  final PlatformChannel _channel;

  @override
  Future<void> setLaunchAtLogin(bool enabled) {
    return _channel.invoke<void>('setLaunchAtLogin', {'enabled': enabled});
  }

  @override
  Future<void> setDockVisible(bool visible) {
    return _channel.invoke<void>('setDockVisible', {'visible': visible});
  }

  @override
  Future<void> setStatusBarVisible(bool visible) {
    return _channel.invoke<void>('setStatusBarVisible', {'visible': visible});
  }

  @override
  Future<void> setMagneticSnap(bool enabled) {
    return _channel.invoke<void>('setMagneticSnap', {'enabled': enabled});
  }
}
