import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/ms_icon.dart';
import '../../domain/entities/history_entry.dart';
import '../../domain/entities/usage_stats.dart';
import '../cubits/history_cubit.dart';

/// Ícone e cor por tipo de evento.
({String icon, Color color}) historyVisual(
  FlowDeskColors colors,
  HistoryEntryType type,
) {
  return switch (type) {
    HistoryEntryType.layout => (
      icon: 'dashboard_customize',
      color: colors.blue,
    ),
    HistoryEntryType.workspace => (icon: 'workspaces', color: colors.green),
    HistoryEntryType.rule => (icon: 'account_tree', color: colors.purple),
  };
}

/// Descrição relativa do momento do evento (ex.: "há 12 minutos").
String relativeTime(DateTime time, {DateTime? now}) {
  final difference = (now ?? DateTime.now()).difference(time);
  if (difference.inMinutes < 1) return 'agora mesmo';
  if (difference.inMinutes < 60) {
    return 'há ${difference.inMinutes} '
        '${difference.inMinutes == 1 ? 'minuto' : 'minutos'}';
  }
  if (difference.inHours < 24) {
    return 'há ${difference.inHours} '
        '${difference.inHours == 1 ? 'hora' : 'horas'}';
  }
  if (difference.inDays < 7) {
    return 'há ${difference.inDays} '
        '${difference.inDays == 1 ? 'dia' : 'dias'}';
  }
  return DateFormat('dd/MM/yyyy', 'pt_BR').format(time);
}

/// Tela de Histórico: timeline das ações do FlowDesk.
class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final HistoryCubit _cubit = getIt<HistoryCubit>();

  @override
  void initState() {
    super.initState();
    _cubit.load();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return BlocBuilder<HistoryCubit, HistoryState>(
      bloc: _cubit,
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            vertical: AppDimens.pagePaddingVertical,
            horizontal: AppDimens.pagePaddingHorizontal,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Histórico',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${state.entries.length} atividades registradas',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      if (state.entries.isNotEmpty)
                        OutlinedButton.icon(
                          onPressed: _cubit.clear,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: colors.text,
                            side: BorderSide(color: colors.cardBorder),
                            textStyle: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          icon: MsIcon(
                            'delete_sweep',
                            size: 15,
                            color: colors.text2,
                          ),
                          label: const Text('Limpar'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (state.entries.isNotEmpty) ...[
                    _StatsCard(stats: UsageStats.fromEntries(state.entries)),
                    const SizedBox(height: AppDimens.gridGap),
                  ],
                  if (state.entries.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Text(
                          state.isLoading
                              ? 'Carregando histórico…'
                              : 'Nenhuma atividade ainda — aplique um layout '
                                    'ou ative um workspace.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: colors.card,
                        borderRadius: BorderRadius.circular(
                          AppDimens.radiusCard,
                        ),
                        border: Border.all(color: colors.cardBorder),
                      ),
                      child: Column(
                        children: [
                          for (var i = 0; i < state.entries.length; i++)
                            _TimelineRow(
                              entry: state.entries[i],
                              isLast: i == state.entries.length - 1,
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Rankings de mais usados derivados do histórico.
class _StatsCard extends StatelessWidget {
  const _StatsCard({required this.stats});

  final UsageStats stats;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(AppDimens.cardPadding),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(AppDimens.radiusCardLarge),
        border: Border.all(color: colors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Estatísticas', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _RankColumn(
                  title: 'LAYOUTS MAIS USADOS',
                  items: stats.topLayouts,
                  accent: colors.blue,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _RankColumn(
                  title: 'WORKSPACES MAIS USADOS',
                  items: stats.topWorkspaces,
                  accent: colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RankColumn extends StatelessWidget {
  const _RankColumn({
    required this.title,
    required this.items,
    required this.accent,
  });

  final String title;
  final List<UsageCount> items;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final maxCount = items.isEmpty ? 1 : items.first.count;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(height: 8),
        if (items.isEmpty)
          Text(
            'Sem dados ainda.',
            style: TextStyle(fontSize: 11.5, color: colors.text3),
          ),
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        item.title,
                        style: TextStyle(fontSize: 12, color: colors.text),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${item.count}×',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: colors.text2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: item.count / maxCount,
                    minHeight: 4,
                    backgroundColor: colors.hover,
                    color: accent,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.entry, required this.isLast});

  final HistoryEntry entry;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final visual = historyVisual(colors, entry.type);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 28,
                height: 28,
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  color: visual.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: MsIcon(visual.icon, size: 14, color: visual.color),
              ),
              if (!isLast)
                Container(width: 1.5, height: 22, color: colors.separator),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.title,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    [
                      if (entry.subtitle != null) entry.subtitle!,
                      relativeTime(entry.createdAt),
                    ].join(' · '),
                    style: TextStyle(fontSize: 11.5, color: colors.text3),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
