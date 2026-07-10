import 'package:injectable/injectable.dart';

import '../../../../core/platform/platform_channel.dart';
import '../../../../core/platform/platform_event_channel.dart';

/// Acesso ao ShortcutManager (Swift) via MethodChannel/EventChannel.
abstract interface class ShortcutsPlatformDatasource {
  Future<void> registerShortcuts(List<Map<String, Object>> shortcuts);

  Stream<int> pressed();
}

@LazySingleton(as: ShortcutsPlatformDatasource)
class ShortcutsPlatformDatasourceImpl implements ShortcutsPlatformDatasource {
  const ShortcutsPlatformDatasourceImpl(
    @Named('shortcutsChannel') this._channel,
    @Named('shortcutsEventsChannel') this._eventsChannel,
  );

  final PlatformChannel _channel;
  final PlatformEventChannel _eventsChannel;

  @override
  Future<void> registerShortcuts(List<Map<String, Object>> shortcuts) {
    return _channel.invoke<void>('registerShortcuts', {'shortcuts': shortcuts});
  }

  @override
  Stream<int> pressed() =>
      _eventsChannel.receive<Object?>().map((event) => event as int? ?? -1);
}
