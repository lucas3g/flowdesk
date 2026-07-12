import 'package:equatable/equatable.dart';

/// Chave estável de um monitor entre sessões (`nome:LARGURAxALTURA` em
/// pixels), já que [Monitor.id] é volátil (CGDirectDisplayID/HMONITOR).
/// Dois monitores idênticos de mesmo nome colidem — limitação aceita,
/// igual ao fingerprint de combinação de telas.
String monitorKey(Monitor monitor) =>
    '${monitor.name}:${monitor.pixelWidth}x${monitor.pixelHeight}';

/// Monitor físico conectado ao Mac.
///
/// Posição e tamanho estão em pontos (coordenadas do macOS);
/// [pixelWidth]/[pixelHeight] são a resolução nativa em pixels.
class Monitor extends Equatable {
  const Monitor({
    required this.id,
    required this.name,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    this.visibleX = 0,
    this.visibleY = 0,
    this.visibleWidth = 0,
    this.visibleHeight = 0,
    required this.pixelWidth,
    required this.pixelHeight,
    required this.scale,
    required this.refreshRate,
    required this.isPrimary,
    required this.isBuiltIn,
  });

  /// CGDirectDisplayID do macOS.
  final int id;
  final String name;
  final double x;
  final double y;
  final double width;
  final double height;

  /// Área útil (sem menu bar/Dock) em coordenadas CG, para posicionar janelas.
  final double visibleX;
  final double visibleY;
  final double visibleWidth;
  final double visibleHeight;
  final int pixelWidth;
  final int pixelHeight;

  /// Fator Retina (1×, 2×…).
  final double scale;

  /// Em Hz; 0 quando o sistema não informa.
  final double refreshRate;
  final bool isPrimary;
  final bool isBuiltIn;

  bool get isPortrait => height > width;

  /// Resolução formatada, ex.: "3840 × 2160".
  String get resolutionLabel => '$pixelWidth × $pixelHeight';

  @override
  List<Object?> get props => [
    id,
    name,
    x,
    y,
    width,
    height,
    visibleX,
    visibleY,
    visibleWidth,
    visibleHeight,
    pixelWidth,
    pixelHeight,
    scale,
    refreshRate,
    isPrimary,
    isBuiltIn,
  ];
}
