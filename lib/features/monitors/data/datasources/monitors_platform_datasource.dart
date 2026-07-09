import 'package:injectable/injectable.dart';

import '../../../../core/platform/platform_channel.dart';
import '../../../../core/platform/platform_event_channel.dart';

/// Acesso ao MonitorManager (Swift) via MethodChannel/EventChannel.
abstract interface class MonitorsPlatformDatasource {
  Future<Object?> getMonitors();

  Stream<Object?> watchMonitors();
}

@LazySingleton(as: MonitorsPlatformDatasource)
class MonitorsPlatformDatasourceImpl implements MonitorsPlatformDatasource {
  const MonitorsPlatformDatasourceImpl(
    @Named('monitorsChannel') this._channel,
    @Named('monitorsEventsChannel') this._eventsChannel,
  );

  final PlatformChannel _channel;
  final PlatformEventChannel _eventsChannel;

  @override
  Future<Object?> getMonitors() => _channel.invoke<Object?>('getMonitors');

  @override
  Stream<Object?> watchMonitors() => _eventsChannel.receive<Object?>();
}
