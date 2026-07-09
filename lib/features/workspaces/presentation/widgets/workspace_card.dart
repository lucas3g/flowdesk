import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/ms_icon.dart';
import '../../../layouts/presentation/widgets/layout_preview.dart';
import '../../domain/entities/workspace.dart';

/// Card de workspace: emoji com gradiente, nome, atalho, apps e ações.
class WorkspaceCard extends StatelessWidget {
  const WorkspaceCard({
    super.key,
    required this.workspace,
    required this.layoutName,
    required this.isApplying,
    required this.onApply,
    required this.onEdit,
    required this.onDelete,
  });

  final Workspace workspace;

  /// Nome do layout vinculado (null quando não há).
  final String? layoutName;
  final bool isApplying;
  final VoidCallback onApply;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final gradientStart = colorFromHex(workspace.gradientStartHex);
    final gradientEnd = colorFromHex(workspace.gradientEndHex);

    return Container(
      padding: const EdgeInsets.all(AppDimens.cardPadding),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(AppDimens.radiusCardLarge),
        border: Border.all(
          color: workspace.isActive ? colors.green : colors.cardBorder,
          width: workspace.isActive ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [gradientStart, gradientEnd],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  workspace.emoji,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      workspace.name,
                      style: Theme.of(context).textTheme.titleSmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${workspace.apps.length} apps'
                      '${layoutName != null ? ' · layout $layoutName' : ''}',
                      style: TextStyle(fontSize: 11.5, color: colors.text3),
                    ),
                  ],
                ),
              ),
              if (workspace.shortcut != null)
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
                    workspace.shortcut!,
                    style: TextStyle(fontSize: 10.5, color: colors.text3),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final app in workspace.apps)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: colors.hover,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    app.appName,
                    style: TextStyle(fontSize: 11, color: colors.text2),
                  ),
                ),
              if (workspace.apps.isEmpty)
                Text(
                  'Nenhum app associado',
                  style: TextStyle(fontSize: 11.5, color: colors.text3),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: workspace.isActive
                    ? OutlinedButton.icon(
                        onPressed: isApplying ? null : onApply,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colors.green,
                          side: BorderSide(
                            color: colors.green.withValues(alpha: 0.5),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          textStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        icon: isApplying
                            ? _spinner(colors.green)
                            : MsIcon('check', size: 14, color: colors.green),
                        label: const Text('Ativo'),
                      )
                    : FilledButton.icon(
                        onPressed: isApplying ? null : onApply,
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          textStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        icon: isApplying
                            ? _spinner(Colors.white)
                            : const MsIcon(
                                'bolt',
                                size: 14,
                                color: Colors.white,
                              ),
                        label: Text(isApplying ? 'Aplicando…' : 'Ativar'),
                      ),
              ),
              const SizedBox(width: 6),
              _IconAction(
                icon: 'edit',
                tooltip: 'Editar',
                onPressed: onEdit,
              ),
              _IconAction(
                icon: 'delete',
                tooltip: 'Excluir',
                onPressed: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _spinner(Color color) {
    return SizedBox(
      width: 13,
      height: 13,
      child: CircularProgressIndicator(strokeWidth: 2, color: color),
    );
  }
}

class _IconAction extends StatelessWidget {
  const _IconAction({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final String icon;
  final String tooltip;
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
          child: Center(child: MsIcon(icon, size: 16, color: colors.text3)),
        ),
      ),
    );
  }
}
