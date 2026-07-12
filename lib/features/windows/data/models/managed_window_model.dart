import 'dart:typed_data';

import '../../domain/entities/managed_window.dart';

/// Conversão do payload do WindowManager (Swift) para a entidade.
abstract final class ManagedWindowModel {
  static ManagedWindow fromMap(Map<String, dynamic> map) {
    final iconBytes = map['icon'];
    return ManagedWindow(
      id: (map['id'] as num?)?.toInt() ?? 0,
      pid: (map['pid'] as num?)?.toInt() ?? 0,
      appName: map['appName'] as String? ?? 'App',
      bundleId: map['bundleId'] as String? ?? '',
      title: map['title'] as String? ?? '',
      x: (map['x'] as num?)?.toDouble() ?? 0,
      y: (map['y'] as num?)?.toDouble() ?? 0,
      width: (map['width'] as num?)?.toDouble() ?? 0,
      height: (map['height'] as num?)?.toDouble() ?? 0,
      monitorId: (map['monitorId'] as num?)?.toInt() ?? 0,
      isFocused: map['isFocused'] == true,
      isMinimized: map['isMinimized'] == true,
      icon: iconBytes is Uint8List && iconBytes.isNotEmpty ? iconBytes : null,
    );
  }

  /// Converte a lista crua vinda do canal.
  static List<ManagedWindow> listFromChannel(Object? payload) {
    if (payload is! List) return const [];
    return payload
        .whereType<Map<Object?, Object?>>()
        .map((raw) => fromMap(raw.map((key, value) => MapEntry('$key', value))))
        .toList(growable: false);
  }
}
