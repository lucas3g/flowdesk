import 'package:flutter/material.dart';

import '../../domain/entities/layout.dart';

/// Converte `#RRGGBB` na cor correspondente.
Color colorFromHex(String hex, {Color fallback = const Color(0xFF0A84FF)}) {
  final cleaned = hex.replaceAll('#', '');
  if (cleaned.length != 6) return fallback;
  final value = int.tryParse(cleaned, radix: 16);
  return value == null ? fallback : Color(0xFF000000 | value);
}

/// Miniatura das regiões de um layout sobre um "wallpaper" em gradiente,
/// como nos cards do design.
class LayoutPreview extends StatelessWidget {
  const LayoutPreview({
    super.key,
    required this.layout,
    this.showLabels = true,
  });

  final Layout layout;
  final bool showLabels;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2C3550), Color(0xFF1A2138)],
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                for (final region in layout.regions)
                  Positioned(
                    left: region.x / 100 * constraints.maxWidth + 2,
                    top: region.y / 100 * constraints.maxHeight + 2,
                    width: region.width / 100 * constraints.maxWidth - 4,
                    height: region.height / 100 * constraints.maxHeight - 4,
                    child: _RegionBox(region: region, showLabel: showLabels),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _RegionBox extends StatelessWidget {
  const _RegionBox({required this.region, required this.showLabel});

  final LayoutRegion region;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final color = colorFromHex(region.colorHex);
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: color, width: 1.2),
      ),
      alignment: Alignment.center,
      clipBehavior: Clip.hardEdge,
      child: showLabel
          ? FittedBox(
              fit: BoxFit.scaleDown,
              child: Padding(
                padding: const EdgeInsets.all(2),
                child: Text(
                  region.name,
                  style: const TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            )
          : null,
    );
  }
}
