import 'package:injectable/injectable.dart';

import '../../../../core/platform/platform_channel.dart';
import '../../domain/entities/app_settings.dart';

/// Acesso aos managers de sistema (StatusBar/LaunchAtLogin/Snap) via canal
/// `flowdesk/app`.
abstract interface class SystemPlatformDatasource {
  Future<void> setLaunchAtLogin(bool enabled);

  Future<void> setDockVisible(bool visible);

  Future<void> setStatusBarVisible(bool visible);

  Future<void> setMagneticSnap(bool enabled);

  Future<void> setLayoutSnapRegions({
    required bool enabled,
    required List<({double x, double y, double width, double height})> regions,
  });

  Future<void> setSnapExcludedApps(List<SnapExcludedApp> apps);
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

  @override
  Future<void> setLayoutSnapRegions({
    required bool enabled,
    required List<({double x, double y, double width, double height})> regions,
  }) {
    return _channel.invoke<void>('setLayoutSnapRegions', {
      'enabled': enabled,
      'regions': [
        for (final region in regions)
          {
            'x': region.x,
            'y': region.y,
            'width': region.width,
            'height': region.height,
          },
      ],
    });
  }

  @override
  Future<void> setSnapExcludedApps(List<SnapExcludedApp> apps) {
    return _channel.invoke<void>('setSnapExcludedApps', {
      'apps': [
        for (final app in apps)
          {
            'bundleId': app.bundleId,
            // 0 exclui o app inteiro; senão, só a janela com esse id.
            'windowId': app.windowId ?? 0,
          },
      ],
    });
  }
}
