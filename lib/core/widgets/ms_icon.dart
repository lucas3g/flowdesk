import 'package:flutter/material.dart';

/// Ícone da fonte variável Material Symbols Rounded, renderizado por ligadura
/// (o [name] é o nome do glifo, ex.: `space_dashboard`).
///
/// O eixo `FILL` reproduz o estado ativo/inativo usado no design.
class MsIcon extends StatelessWidget {
  const MsIcon(
    this.name, {
    super.key,
    this.size = 19,
    this.color,
    this.filled = false,
    this.weight = 500,
  });

  final String name;
  final double size;
  final Color? color;
  final bool filled;
  final double weight;

  @override
  Widget build(BuildContext context) {
    return Text(
      name,
      style: TextStyle(
        fontFamily: 'MaterialSymbolsRounded',
        fontSize: size,
        height: 1,
        color: color ?? IconTheme.of(context).color,
        fontVariations: [
          FontVariation('FILL', filled ? 1 : 0),
          FontVariation('wght', weight),
          const FontVariation('GRAD', 0),
          const FontVariation('opsz', 24),
        ],
      ),
    );
  }
}
