import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/routing/app_screen.dart';
import '../../../../core/routing/navigation_cubit.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/command_palette.dart';
import '../../../../core/widgets/ms_icon.dart';
import '../../../history/domain/entities/history_entry.dart';
import '../../../history/presentation/cubits/history_cubit.dart';
import '../../../layout_editor/presentation/cubits/layout_editor_cubit.dart';
import '../../../layouts/presentation/cubits/layouts_cubit.dart';
import '../../../layouts/presentation/cubits/layouts_state.dart';
import '../../../monitors/presentation/cubits/monitors_cubit.dart';
import '../../../monitors/presentation/cubits/monitors_state.dart';
import '../../../windows/presentation/cubits/windows_cubit.dart';
import '../../../windows/presentation/cubits/windows_state.dart';
import '../../../settings/presentation/cubits/settings_cubit.dart';
import '../../../workspaces/presentation/cubits/workspaces_cubit.dart';
import '../../../workspaces/presentation/cubits/workspaces_state.dart';
import '../widgets/dashboard_widgets.dart';

/// Saudação conforme a hora do dia.
String greetingForHour(int hour) {
  if (hour < 12) return 'Bom dia';
  if (hour < 18) return 'Boa tarde';
  return 'Boa noite';
}

/// Dashboard: visão geral com dados reais de todos os cubits.
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final MonitorsCubit _monitorsCubit = getIt<MonitorsCubit>();
  final WindowsCubit _windowsCubit = getIt<WindowsCubit>();
  final WorkspacesCubit _workspacesCubit = getIt<WorkspacesCubit>();
  final LayoutsCubit _layoutsCubit = getIt<LayoutsCubit>();
  final HistoryCubit _historyCubit = getIt<HistoryCubit>();
  final NavigationCubit _navigationCubit = getIt<NavigationCubit>();
  final SettingsCubit _settingsCubit = getIt<SettingsCubit>();
  final LayoutEditorCubit _layoutEditorCubit = getIt<LayoutEditorCubit>();

  static final NumberFormat _pxFormat = NumberFormat.decimalPattern('pt_BR');

  @override
  void initState() {
    super.initState();
    _windowsCubit.refresh();
    _layoutsCubit.load();
    _workspacesCubit.load();
    _historyCubit.load();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MonitorsCubit, MonitorsState>(
      bloc: _monitorsCubit,
      builder: (context, monitorsState) {
        return BlocBuilder<WindowsCubit, WindowsState>(
          bloc: _windowsCubit,
          builder: (context, windowsState) {
            return BlocBuilder<WorkspacesCubit, WorkspacesState>(
              bloc: _workspacesCubit,
              builder: (context, workspacesState) {
                return BlocBuilder<LayoutsCubit, LayoutsState>(
                  bloc: _layoutsCubit,
                  builder: (context, layoutsState) {
                    return BlocBuilder<HistoryCubit, HistoryState>(
                      bloc: _historyCubit,
                      builder: (context, historyState) => _buildContent(
                        context,
                        monitorsState,
                        windowsState,
                        workspacesState,
                        layoutsState,
                        historyState,
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildContent(
    BuildContext context,
    MonitorsState monitorsState,
    WindowsState windowsState,
    WorkspacesState workspacesState,
    LayoutsState layoutsState,
    HistoryState historyState,
  ) {
    final colors = context.colors;
    final activeWorkspace = workspacesState.workspaces
        .where((workspace) => workspace.isActive)
        .firstOrNull;
    final favorites = layoutsState.layouts
        .where((layout) => layout.isFavorite)
        .take(3)
        .toList(growable: false);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        vertical: AppDimens.pagePaddingVertical,
        horizontal: AppDimens.pagePaddingHorizontal,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabeçalho: saudação + ações principais.
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Builder(
                          builder: (context) {
                            final name = _settingsCubit
                                .state
                                .settings
                                .userName
                                .trim();
                            final greeting = greetingForHour(
                              DateTime.now().hour,
                            );
                            return Text(
                              name.isEmpty ? greeting : '$greeting, $name',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: colors.text2,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Bom fluxo de trabalho hoje',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ],
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: () {
                      // Criar sempre parte de um layout em branco — sem isso,
                      // o editor (singleton) reabre o último layout editado.
                      _layoutEditorCubit.newLayout();
                      _navigationCubit.navigate(AppScreen.layoutEditor);
                    },
                    icon: const MsIcon('add', size: 15, color: Colors.white),
                    label: const Text('Criar Layout'),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () => showCommandPalette(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colors.text,
                      side: BorderSide(color: colors.cardBorder),
                      textStyle: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    icon: MsIcon('bolt', size: 15, color: colors.green),
                    label: const Text('Aplicar Layout'),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              // Stat cards.
              LayoutBuilder(
                builder: (context, constraints) {
                  const gap = AppDimens.gridGap;
                  final columns = constraints.maxWidth > 820 ? 4 : 2;
                  final width =
                      (constraints.maxWidth - gap * (columns - 1)) / columns;
                  return Wrap(
                    spacing: gap,
                    runSpacing: gap,
                    children: [
                      SizedBox(
                        width: width,
                        child: StatCard(
                          icon: 'monitor',
                          accent: colors.blue,
                          value: '${monitorsState.monitors.length}',
                          label: 'Monitores ativos',
                          trend:
                              '${_pxFormat.format(monitorsState.totalPixelWidth)}'
                              ' px de largura',
                          trendIcon: 'straighten',
                        ),
                      ),
                      SizedBox(
                        width: width,
                        child: StatCard(
                          icon: 'select_window',
                          accent: colors.green,
                          value: '${windowsState.windows.length}',
                          label: 'Janelas abertas',
                          trend: windowsState.status == WindowsStatus.ready
                              ? 'atualizado agora'
                              : 'carregando…',
                          trendIcon: 'trending_up',
                        ),
                      ),
                      SizedBox(
                        width: width,
                        child: StatCard(
                          icon: 'workspaces',
                          accent: colors.purple,
                          value: '${workspacesState.workspaces.length}',
                          label: 'Workspaces',
                          trend: activeWorkspace != null
                              ? '${activeWorkspace.name} ativo'
                              : 'nenhum ativo',
                          trendIcon: 'bolt',
                        ),
                      ),
                      SizedBox(
                        width: width,
                        child: StatCard(
                          icon: 'dashboard_customize',
                          accent: colors.orange,
                          value: '${layoutsState.layouts.length}',
                          label: 'Layouts salvos',
                          trend: '${layoutsState.favoritesCount} favoritos',
                          trendIcon: 'star',
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: AppDimens.gridGap),
              // Duas colunas: principal + lateral.
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 840;
                  final left = _buildLeftColumn(
                    context,
                    activeWorkspace,
                    layoutsState,
                    historyState,
                  );
                  final right = _buildRightColumn(
                    context,
                    monitorsState,
                    favorites,
                    historyState,
                  );
                  if (!isWide) {
                    return Column(
                      children: [
                        left,
                        const SizedBox(height: AppDimens.gridGap),
                        right,
                      ],
                    );
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: left),
                      const SizedBox(width: AppDimens.gridGap),
                      Expanded(flex: 2, child: right),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeftColumn(
    BuildContext context,
    dynamic activeWorkspace,
    LayoutsState layoutsState,
    HistoryState historyState,
  ) {
    // Layouts usados recentemente (via histórico), com fallback aos primeiros.
    final recentNames = <String>{};
    for (final entry in historyState.entries) {
      if (entry.type == HistoryEntryType.layout) {
        final match = RegExp("Aplicou '(.+)'").firstMatch(entry.title);
        if (match != null) recentNames.add(match.group(1)!);
      }
      if (recentNames.length >= 3) break;
    }
    final recents = [
      for (final name in recentNames)
        ...layoutsState.layouts.where((layout) => layout.name == name),
      ...layoutsState.layouts.where(
        (layout) => !recentNames.contains(layout.name),
      ),
    ].take(3).toList(growable: false);

    return Column(
      children: [
        if (activeWorkspace != null) ...[
          ActiveWorkspaceBanner(workspace: activeWorkspace),
          const SizedBox(height: AppDimens.gridGap),
        ],
        DashboardCard(
          title: 'Layouts recentes',
          action: 'Ver todos',
          onAction: () => _navigationCubit.navigate(AppScreen.layouts),
          child: Column(
            children: [
              for (final layout in recents)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: RecentLayoutRow(
                    layout: layout,
                    onApply: () => _layoutsCubit.apply(layout),
                  ),
                ),
              if (recents.isEmpty)
                Text(
                  'Nenhum layout ainda.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
            ],
          ),
        ),
        const SizedBox(height: AppDimens.gridGap),
        DashboardCard(
          title: 'Ações rápidas',
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              QuickActionChip(
                icon: 'add_box',
                label: 'Criar Layout',
                onTap: () {
                  // Criar sempre parte de um layout em branco — sem isso,
                  // o editor (singleton) reabre o último layout editado.
                  _layoutEditorCubit.newLayout();
                  _navigationCubit.navigate(AppScreen.layoutEditor);
                },
              ),
              QuickActionChip(
                icon: 'bolt',
                label: 'Aplicar Layout',
                onTap: () => showCommandPalette(context),
              ),
              QuickActionChip(
                icon: 'workspaces',
                label: 'Workspaces',
                onTap: () =>
                    _navigationCubit.navigate(AppScreen.workspaces),
              ),
              QuickActionChip(
                icon: 'keyboard_command_key',
                label: 'Atalhos',
                onTap: () =>
                    _navigationCubit.navigate(AppScreen.shortcuts),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRightColumn(
    BuildContext context,
    MonitorsState monitorsState,
    List favorites,
    HistoryState historyState,
  ) {
    final colors = context.colors;
    return Column(
      children: [
        DashboardCard(
          title: 'Favoritos',
          action: 'Ver todos',
          onAction: () =>
              _navigationCubit.navigate(AppScreen.favorites),
          child: Column(
            children: [
              for (final layout in favorites)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: RecentLayoutRow(
                    layout: layout,
                    compact: true,
                    onApply: () => _layoutsCubit.apply(layout),
                  ),
                ),
              if (favorites.isEmpty)
                Text(
                  'Marque layouts com a estrela.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
            ],
          ),
        ),
        const SizedBox(height: AppDimens.gridGap),
        DashboardCard(
          title: 'Seus monitores',
          action: 'Detalhes',
          onAction: () => _navigationCubit.navigate(AppScreen.monitors),
          child: MiniMonitors(monitors: monitorsState.monitors),
        ),
        const SizedBox(height: AppDimens.gridGap),
        DashboardCard(
          title: 'Atividade recente',
          action: 'Histórico',
          onAction: () => _navigationCubit.navigate(AppScreen.history),
          child: Column(
            children: [
              for (final entry in historyState.entries.take(4))
                ActivityRow(entry: entry),
              if (historyState.entries.isEmpty)
                Text(
                  'Nenhuma atividade ainda.',
                  style: TextStyle(fontSize: 12, color: colors.text3),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
