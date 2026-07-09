import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/ms_icon.dart';
import '../../domain/entities/layout.dart';
import 'layout_preview.dart';

/// Card da galeria: preview das regiões, nome, meta, atalho e ações.
class LayoutCard extends StatelessWidget {
  const LayoutCard({
    super.key,
    required this.layout,
    required this.onApply,
    required this.onEdit,
    required this.onToggleFavorite,
    this.onDelete,
  });

  final Layout layout;
  final VoidCallback onApply;

  /// Abre o layout no editor (presets abrem como cópia).
  final VoidCallback onEdit;
  final VoidCallback onToggleFavorite;

  /// Null para presets (não podem ser excluídos).
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(AppDimens.radiusCardLarge),
        border: Border.all(color: colors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9.5,
            child: LayoutPreview(layout: layout),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      layout.name,
                      style: Theme.of(context).textTheme.titleSmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${layout.regions.length} '
                      '${layout.regions.length == 1 ? 'região' : 'regiões'}'
                      ' · ${layout.category.label}',
                      style: TextStyle(fontSize: 11, color: colors.text3),
                    ),
                  ],
                ),
              ),
              if (layout.shortcut != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: colors.cardBorder),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    layout.shortcut!,
                    style: TextStyle(fontSize: 10.5, color: colors.text3),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: onApply,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    textStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  icon: const MsIcon('bolt', size: 14, color: Colors.white),
                  label: const Text('Aplicar'),
                ),
              ),
              const SizedBox(width: 6),
              _IconAction(
                icon: 'edit',
                tooltip: layout.isPreset ? 'Editar como cópia' : 'Editar',
                color: colors.text3,
                onPressed: onEdit,
              ),
              _IconAction(
                icon: 'star',
                tooltip: layout.isFavorite
                    ? 'Remover dos favoritos'
                    : 'Favoritar',
                color: layout.isFavorite ? colors.orange : colors.text3,
                filled: layout.isFavorite,
                onPressed: onToggleFavorite,
              ),
              if (onDelete != null)
                _IconAction(
                  icon: 'delete',
                  tooltip: 'Excluir',
                  color: colors.text3,
                  onPressed: onDelete!,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _IconAction extends StatelessWidget {
  const _IconAction({
    required this.icon,
    required this.tooltip,
    required this.color,
    required this.onPressed,
    this.filled = false,
  });

  final String icon;
  final String tooltip;
  final Color color;
  final bool filled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Tooltip(
      message: tooltip,
      waitDuration: const Duration(milliseconds: 400),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(7),
        hoverColor: colors.hover,
        child: SizedBox(
          width: 32,
          height: 32,
          child: Center(
            child: MsIcon(icon, size: 16, color: color, filled: filled),
          ),
        ),
      ),
    );
  }
}
