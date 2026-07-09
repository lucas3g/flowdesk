import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../domain/entities/monitor.dart';

/// Cor de destaque de cada monitor, rotacionando a paleta do design.
Color monitorAccent(FlowDeskColors colors, int index) {
  final palette = [colors.teal, colors.blue, colors.purple, colors.green];
  return palette[index % palette.length];
}

/// Visualização em escala dos monitores lado a lado, como no design:
/// retângulos proporcionais, selecionáveis, com badge "principal".
class MonitorStage extends StatelessWidget {
  const MonitorStage({
    super.key,
    required this.monitors,
    required this.selectedId,
    required this.onSelect,
  });

  final List<Monitor> monitors;
  final int? selectedId;
  final ValueChanged<int> onSelect;

  static const double _stageHeight = 170;
  static const double _boxHeight = 96;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      height: _stageHeight,
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(AppDimens.radiusCardLarge),
        border: Border.all(color: colors.cardBorder),
      ),
      child: monitors.isEmpty
          ? Center(
              child: Text(
                'Nenhum monitor detectado',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                for (var i = 0; i < monitors.length; i++) ...[
                  if (i > 0) const SizedBox(width: 18),
                  _MonitorBox(
                    monitor: monitors[i],
                    accent: monitorAccent(colors, i),
                    selected: monitors[i].id == selectedId,
                    onTap: () => onSelect(monitors[i].id),
                  ),
                ],
              ],
            ),
    );
  }
}

class _MonitorBox extends StatelessWidget {
  const _MonitorBox({
    required this.monitor,
    required this.accent,
    required this.selected,
    required this.onTap,
  });

  final Monitor monitor;
  final Color accent;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final aspect = monitor.width <= 0 || monitor.height <= 0
        ? 16 / 9
        : monitor.width / monitor.height;
    final boxWidth = (MonitorStage._boxHeight * aspect).clamp(48.0, 260.0);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: AppDimens.transitionFast,
            width: boxWidth,
            height: MonitorStage._boxHeight,
            decoration: BoxDecoration(
              color: selected
                  ? accent.withValues(alpha: 0.85)
                  : accent.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: accent, width: 1.5),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: accent.withValues(alpha: 0.45),
                        blurRadius: 18,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : const [],
            ),
            alignment: Alignment.center,
            child: monitor.isPrimary
                ? Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: selected ? Colors.white : accent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'principal',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: selected ? accent : Colors.white,
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 8),
          Text(
            monitor.name,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: selected ? colors.text : colors.text2,
            ),
          ),
          Text(
            monitor.resolutionLabel,
            style: TextStyle(fontSize: 10.5, color: colors.text3),
          ),
        ],
      ),
    );
  }
}
