import '../../domain/entities/monitor.dart';

/// Conversão do payload do MonitorManager (Swift) para a entidade.
abstract final class MonitorModel {
  static Monitor fromMap(Map<String, dynamic> map) {
    return Monitor(
      id: (map['id'] as num?)?.toInt() ?? 0,
      name: map['name'] as String? ?? 'Monitor',
      x: (map['x'] as num?)?.toDouble() ?? 0,
      y: (map['y'] as num?)?.toDouble() ?? 0,
      width: (map['width'] as num?)?.toDouble() ?? 0,
      height: (map['height'] as num?)?.toDouble() ?? 0,
      visibleX: (map['visibleX'] as num?)?.toDouble() ?? 0,
      visibleY: (map['visibleY'] as num?)?.toDouble() ?? 0,
      visibleWidth: (map['visibleWidth'] as num?)?.toDouble() ?? 0,
      visibleHeight: (map['visibleHeight'] as num?)?.toDouble() ?? 0,
      pixelWidth: (map['pixelWidth'] as num?)?.toInt() ?? 0,
      pixelHeight: (map['pixelHeight'] as num?)?.toInt() ?? 0,
      scale: (map['scale'] as num?)?.toDouble() ?? 1,
      refreshRate: (map['refreshRate'] as num?)?.toDouble() ?? 0,
      isPrimary: map['isPrimary'] == true,
      isBuiltIn: map['isBuiltIn'] == true,
    );
  }

  /// Converte a lista crua vinda do canal (List de Map com chaves Object?).
  static List<Monitor> listFromChannel(Object? payload) {
    if (payload is! List) return const [];
    return payload
        .whereType<Map<Object?, Object?>>()
        .map((raw) => fromMap(raw.map((key, value) => MapEntry('$key', value))))
        .toList(growable: false);
  }
}
