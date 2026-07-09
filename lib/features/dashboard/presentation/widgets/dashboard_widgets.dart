import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/ms_icon.dart';
import '../../../history/domain/entities/history_entry.dart';
import '../../../history/presentation/pages/history_page.dart';
import '../../../layouts/domain/entities/layout.dart';
import '../../../layouts/presentation/widgets/layout_preview.dart';
import '../../../monitors/domain/entities/monitor.dart';
import '../../../monitors/presentation/widgets/monitor_stage.dart';
import '../../../workspaces/domain/entities/workspace.dart';

/// Card numérico do topo do dashboard.
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.icon,
    required this.accent,
    required this.value,
    required this.label,
    required this.trend,
    required this.trendIcon,
  });

  final String icon;
  final Color accent;
  final String value;
  final String label;
  final String trend;
  final String trendIcon;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(AppDimens.cardPadding),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        border: Border.all(color: colors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(9),
            ),
            alignment: Alignment.center,
            child: MsIcon(icon, size: 17, color: accent),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: colors.text,
            ),
          ),
          Text(label, style: TextStyle(fontSize: 12, color: colors.text2)),
          const SizedBox(height: 6),
          Row(
            children: [
              MsIcon(trendIcon, size: 12, color: accent),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  trend,
                  style: TextStyle(fontSize: 11, color: colors.text3),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Card genérico de seção do dashboard.
class DashboardCard extends StatelessWidget {
  const DashboardCard({
    super.key,
    required this.title,
    required this.child,
    this.action,
    this.onAction,
  });

  final String title;
  final Widget child;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimens.cardPadding),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(AppDimens.radiusCardLarge),
        border: Border.all(color: colors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              if (action != null)
                InkWell(
                  onTap: onAction,
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    child: Text(
                      action!,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: colors.blue,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

/// Banner do workspace ativo.
class ActiveWorkspaceBanner extends StatelessWidget {
  const ActiveWorkspaceBanner({super.key, required this.workspace});

  final Workspace workspace;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimens.cardPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            colorFromHex(workspace.gradientStartHex).withValues(alpha: 0.18),
            colorFromHex(workspace.gradientEndHex).withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(AppDimens.radiusCardLarge),
        border: Border.all(color: colors.cardBorder),
      ),
      child: Row(
        children: [
          Text(workspace.emoji, style: const TextStyle(fontSize: 26)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Workspace atual',
                  style: TextStyle(fontSize: 11, color: colors.text3),
                ),
                Text(
                  workspace.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  '${workspace.apps.length} apps'
                  '${workspace.shortcut != null ? ' · ${workspace.shortcut}' : ''}',
                  style: TextStyle(fontSize: 11.5, color: colors.text2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Linha de layout com preview e aplicação rápida.
class RecentLayoutRow extends StatelessWidget {
  const RecentLayoutRow({
    super.key,
    required this.layout,
    required this.onApply,
    this.compact = false,
  });

  final Layout layout;
  final VoidCallback onApply;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      children: [
        SizedBox(
          width: compact ? 46 : 64,
          height: compact ? 28 : 40,
          child: LayoutPreview(layout: layout, showLabels: false),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      layout.name,
                      style: Theme.of(context).textTheme.bodyMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (layout.isFavorite) ...[
                    const SizedBox(width: 4),
                    MsIcon('star', size: 12, filled: true, color: colors.orange),
                  ],
                ],
              ),
              Text(
                '${layout.regions.length} regiões',
                style: TextStyle(fontSize: 11, color: colors.text3),
              ),
            ],
          ),
        ),
        if (layout.shortcut != null)
          Container(
            margin: const EdgeInsets.only(right: 6),
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
              border: Border.all(color: colors.cardBorder),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              layout.shortcut!,
              style: TextStyle(fontSize: 10, color: colors.text3),
            ),
          ),
        Tooltip(
          message: 'Aplicar',
          child: InkWell(
            onTap: onApply,
            borderRadius: BorderRadius.circular(7),
            hoverColor: colors.hover,
            child: SizedBox(
              width: 28,
              height: 28,
              child: Center(
                child: MsIcon('bolt', size: 15, color: colors.blue),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Chip de ação rápida.
class QuickActionChip extends StatelessWidget {
  const QuickActionChip({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final String icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimens.radiusIconButton),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: colors.hover,
          borderRadius: BorderRadius.circular(AppDimens.radiusIconButton),
          border: Border.all(color: colors.cardBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            MsIcon(icon, size: 15, color: colors.blue),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: colors.text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Mini visualização dos monitores.
class MiniMonitors extends StatelessWidget {
  const MiniMonitors({super.key, required this.monitors});

  final List<Monitor> monitors;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    if (monitors.isEmpty) {
      return Text(
        'Nenhum monitor detectado.',
        style: TextStyle(fontSize: 12, color: colors.text3),
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (var i = 0; i < monitors.length; i++) ...[
          if (i > 0) const SizedBox(width: 10),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: (44 * (monitors[i].width / monitors[i].height))
                    .clamp(24.0, 110.0),
                height: 44,
                decoration: BoxDecoration(
                  color: monitorAccent(colors, i).withValues(alpha: 0.2),
                  border: Border.all(color: monitorAccent(colors, i)),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                monitors[i].isPrimary ? 'principal' : monitors[i].name,
                style: TextStyle(fontSize: 9.5, color: colors.text3),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ],
    );
  }
}

/// Linha da atividade recente.
class ActivityRow extends StatelessWidget {
  const ActivityRow({super.key, required this.entry});

  final HistoryEntry entry;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final visual = historyVisual(colors, entry.type);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: visual.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(7),
            ),
            alignment: Alignment.center,
            child: MsIcon(visual.icon, size: 12, color: visual.color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.title,
                  style: TextStyle(fontSize: 12, color: colors.text),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  relativeTime(entry.createdAt),
                  style: TextStyle(fontSize: 10.5, color: colors.text3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
