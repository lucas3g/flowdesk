import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/ms_icon.dart';
import '../../../monitors/domain/entities/monitor.dart';
import '../../domain/entities/managed_window.dart';
import '../cubits/windows_cubit.dart';
import '../cubits/windows_state.dart';
import '../widgets/window_row.dart';

/// Tela de Janelas: tabs por monitor, busca e ações por janela.
class WindowsPage extends StatefulWidget {
  const WindowsPage({super.key});

  @override
  State<WindowsPage> createState() => _WindowsPageState();
}

class _WindowsPageState extends State<WindowsPage> {
  final WindowsCubit _cubit = getIt<WindowsCubit>();

  @override
  void initState() {
    super.initState();
    _cubit.refresh();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return BlocBuilder<WindowsCubit, WindowsState>(
      bloc: _cubit,
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            vertical: AppDimens.pagePaddingVertical,
            horizontal: AppDimens.pagePaddingHorizontal,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, colors, state),
                  const SizedBox(height: 16),
                  _buildTabs(colors, state),
                  const SizedBox(height: AppDimens.gridGap),
                  if (state.status == WindowsStatus.error)
                    _buildError(colors, state)
                  else
                    ..._buildGroups(context, colors, state),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(
    BuildContext context,
    FlowDeskColors colors,
    WindowsState state,
  ) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Janelas', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 2),
              Text(
                '${state.windows.length} janelas abertas',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        SizedBox(
          width: 240,
          height: 34,
          child: TextField(
            onChanged: _cubit.search,
            style: TextStyle(fontSize: 12.5, color: colors.text),
            decoration: InputDecoration(
              hintText: 'Buscar janela ou app…',
              hintStyle: TextStyle(fontSize: 12.5, color: colors.text3),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 10, right: 6),
                child: MsIcon('search', size: 15, color: colors.text3),
              ),
              prefixIconConstraints: const BoxConstraints(
                minWidth: 0,
                minHeight: 0,
              ),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
              filled: true,
              fillColor: colors.hover,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimens.radiusIconButton),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Tooltip(
          message: 'Atualizar',
          child: InkWell(
            onTap: _cubit.refresh,
            borderRadius: BorderRadius.circular(AppDimens.radiusIconButton),
            hoverColor: colors.hover,
            child: SizedBox(
              width: 34,
              height: 34,
              child: Center(
                child: MsIcon('refresh', size: 16, color: colors.text2),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabs(FlowDeskColors colors, WindowsState state) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _TabPill(
          label: 'Todos (${state.windows.length})',
          active: state.selectedMonitorId == null,
          onTap: () => _cubit.selectMonitor(null),
        ),
        for (final monitor in state.monitors)
          _TabPill(
            label: '${monitor.name} (${state.countForMonitor(monitor.id)})',
            active: state.selectedMonitorId == monitor.id,
            onTap: () => _cubit.selectMonitor(monitor.id),
          ),
      ],
    );
  }

  List<Widget> _buildGroups(
    BuildContext context,
    FlowDeskColors colors,
    WindowsState state,
  ) {
    final filtered = state.filtered;
    if (filtered.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Center(
            child: Text(
              state.status == WindowsStatus.loading
                  ? 'Carregando janelas…'
                  : 'Nenhuma janela encontrada',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ),
      ];
    }

    final visibleMonitors = state.monitors
        .where(
          (monitor) => filtered.any((window) => window.monitorId == monitor.id),
        )
        .toList(growable: false);
    final knownIds = visibleMonitors.map((m) => m.id).toSet();
    final orphans = filtered
        .where((window) => !knownIds.contains(window.monitorId))
        .toList(growable: false);

    return [
      for (final monitor in visibleMonitors) ...[
        _GroupHeader(
          monitor: monitor,
          count: filtered
              .where((window) => window.monitorId == monitor.id)
              .length,
        ),
        _WindowsCard(
          windows: filtered
              .where((window) => window.monitorId == monitor.id)
              .toList(growable: false),
          cubit: _cubit,
        ),
        const SizedBox(height: AppDimens.gridGap),
      ],
      if (orphans.isNotEmpty) _WindowsCard(windows: orphans, cubit: _cubit),
    ];
  }

  Widget _buildError(FlowDeskColors colors, WindowsState state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        border: Border.all(color: colors.red.withValues(alpha: 0.3)),
      ),
      child: Text(
        state.errorMessage ?? 'Não foi possível listar as janelas.',
        style: TextStyle(fontSize: 12.5, color: colors.text2),
      ),
    );
  }
}

class _TabPill extends StatelessWidget {
  const _TabPill({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: AppDimens.transitionFast,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? colors.blue : colors.hover,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: active ? Colors.white : colors.text2,
          ),
        ),
      ),
    );
  }
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({required this.monitor, required this.count});

  final Monitor monitor;
  final int count;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          MsIcon(
            monitor.isBuiltIn ? 'laptop_mac' : 'monitor',
            size: 15,
            color: colors.text2,
          ),
          const SizedBox(width: 8),
          Text(monitor.name, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(width: 8),
          Text(
            '$count ${count == 1 ? 'janela' : 'janelas'}',
            style: TextStyle(fontSize: 11.5, color: colors.text3),
          ),
        ],
      ),
    );
  }
}

class _WindowsCard extends StatelessWidget {
  const _WindowsCard({required this.windows, required this.cubit});

  final List<ManagedWindow> windows;
  final WindowsCubit cubit;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        border: Border.all(color: colors.cardBorder),
      ),
      child: Column(
        children: [
          for (var i = 0; i < windows.length; i++) ...[
            if (i > 0) Divider(height: 1, indent: 56, color: colors.separator),
            WindowRow(
              window: windows[i],
              onFocus: () => cubit.focus(windows[i]),
              onCenter: () => cubit.center(windows[i]),
              onMaximize: () => cubit.maximize(windows[i]),
            ),
          ],
        ],
      ),
    );
  }
}
