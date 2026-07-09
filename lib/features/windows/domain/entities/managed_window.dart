import 'dart:typed_data';

import 'package:equatable/equatable.dart';

/// Janela de outro aplicativo gerenciável pelo FlowDesk.
///
/// Coordenadas no sistema global do CoreGraphics (origem no canto superior
/// esquerdo do monitor principal).
class ManagedWindow extends Equatable {
  const ManagedWindow({
    required this.id,
    required this.pid,
    required this.appName,
    required this.bundleId,
    required this.title,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.monitorId,
    required this.isFocused,
    this.isMinimized = false,
    this.icon,
  });

  /// CGWindowID.
  final int id;
  final int pid;
  final String appName;
  final String bundleId;

  /// Vazio quando a permissão de Gravação de Tela não foi concedida.
  final String title;
  final double x;
  final double y;
  final double width;
  final double height;
  final int monitorId;
  final bool isFocused;

  /// Janela minimizada no Dock (restaurada ao aplicar um layout).
  final bool isMinimized;

  /// PNG 32×32 do ícone do app (null quando indisponível).
  final Uint8List? icon;

  String get displayTitle => title.isEmpty ? appName : title;

  /// Dimensões formatadas, ex.: "2560 × 1440".
  String get sizeLabel => '${width.round()} × ${height.round()}';

  @override
  List<Object?> get props => [
    id,
    pid,
    appName,
    bundleId,
    title,
    x,
    y,
    width,
    height,
    monitorId,
    isFocused,
    isMinimized,
    icon?.length,
  ];
}
