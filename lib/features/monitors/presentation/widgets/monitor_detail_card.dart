import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/ms_icon.dart';
import '../../domain/entities/monitor.dart';

/// Card com as especificações de um monitor; a borda ganha a cor de
/// destaque quando ele está selecionado na visualização.
class MonitorDetailCard extends StatelessWidget {
  const MonitorDetailCard({
    super.key,
    required this.monitor,
    required this.accent,
    required this.selected,
    required this.onTap,
  });

  final Monitor monitor;
  final Color accent;
  final bool selected;
  final VoidCallback onTap;

  String get _scaleLabel {
    final scale = monitor.scale;
    final formatted = scale == scale.roundToDouble()
        ? '${scale.toInt()}×'
        : '${scale.toStringAsFixed(1)}×';
    return scale >= 2 ? '$formatted Retina' : formatted;
  }

  String get _refreshLabel =>
      monitor.refreshRate > 0 ? '${monitor.refreshRate.round()} Hz' : '—';

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimens.radiusCardLarge),
      child: AnimatedContainer(
        duration: AppDimens.transitionFast,
        padding: const EdgeInsets.all(AppDimens.cardPadding),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(AppDimens.radiusCardLarge),
          border: Border.all(
            color: selected ? accent : colors.cardBorder,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: MsIcon(
                    monitor.isBuiltIn ? 'laptop_mac' : 'monitor',
                    size: 16,
                    color: accent,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    monitor.name,
                    style: Theme.of(context).textTheme.titleSmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (monitor.isPrimary)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'principal',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: accent,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            _SpecRow(label: 'Resolução', value: monitor.resolutionLabel),
            _SpecRow(label: 'Escala', value: _scaleLabel),
            _SpecRow(label: 'Taxa de atualização', value: _refreshLabel),
            _SpecRow(
              label: 'Orientação',
              value: monitor.isPortrait ? 'Retrato' : 'Paisagem',
            ),
            _SpecRow(
              label: 'Posição',
              value: '${monitor.x.round()}, ${monitor.y.round()}',
            ),
          ],
        ),
      ),
    );
  }
}

class _SpecRow extends StatelessWidget {
  const _SpecRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: colors.text3)),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: colors.text,
            ),
          ),
        ],
      ),
    );
  }
}
