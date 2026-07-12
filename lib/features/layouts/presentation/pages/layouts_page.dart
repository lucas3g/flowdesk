import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/routing/app_screen.dart';
import '../../../../core/routing/navigation_cubit.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/tour/tour_targets.dart';
import '../../../../core/widgets/ms_icon.dart';
import '../../../layout_editor/presentation/cubits/layout_editor_cubit.dart';
import '../../../monitors/domain/entities/monitor.dart';
import '../../../monitors/presentation/cubits/monitors_cubit.dart';
import '../../../monitors/presentation/cubits/monitors_state.dart';
import '../cubits/applied_layouts_cubit.dart';
import '../cubits/layouts_cubit.dart';
import '../cubits/layouts_state.dart';
import '../widgets/layout_card.dart';

/// Galeria de layouts: busca, filtros, favoritos e aplicação.
class LayoutsPage extends StatefulWidget {
  const LayoutsPage({super.key});

  @override
  State<LayoutsPage> createState() => _LayoutsPageState();
}

class _LayoutsPageState extends State<LayoutsPage> {
  final LayoutsCubit _cubit = getIt<LayoutsCubit>();
  final LayoutEditorCubit _layoutEditorCubit = getIt<LayoutEditorCubit>();
  final NavigationCubit _navigationCubit = getIt<NavigationCubit>();

  @override
  void initState() {
    super.initState();
    _cubit.load();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return BlocListener<LayoutsCubit, LayoutsState>(
      bloc: _cubit,
      listenWhen: (previous, current) =>
          current.feedback != null && previous.feedback != current.feedback,
      listener: (context, state) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(state.feedback!),
              behavior: SnackBarBehavior.floating,
              width: 420,
            ),
          );
        _cubit.clearFeedback();
      },
      child: BlocBuilder<LayoutsCubit, LayoutsState>(
        bloc: _cubit,
        builder: (context, state) {
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
                    _buildHeader(context, colors, state),
                    const SizedBox(height: 16),
                    _buildFilters(state),
                    const SizedBox(height: AppDimens.gridGap),
                    _buildGrid(context, state),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    FlowDeskColors colors,
    LayoutsState state,
  ) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Layouts', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 2),
              Text(
                '${state.layouts.length} layouts salvos'
                ' · ${state.favoritesCount} favoritos',
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
              hintText: 'Buscar layout…',
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
        _MonitorSelector(
          key: TourTargets.monitorSelector,
          cubit: _cubit,
          targetMonitorId: state.targetMonitorId,
        ),
      ],
    );
  }

  Widget _buildFilters(LayoutsState state) {
    final colors = context.colors;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final filter in LayoutsFilter.values)
          InkWell(
            onTap: () => _cubit.setFilter(filter),
            borderRadius: BorderRadius.circular(20),
            child: AnimatedContainer(
              duration: AppDimens.transitionFast,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: state.filter == filter ? colors.blue : colors.hover,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                filter.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: state.filter == filter ? Colors.white : colors.text2,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildGrid(BuildContext context, LayoutsState state) {
    final filtered = state.filtered;

    if (state.status == LayoutsStatus.error) {
      return Text(
        state.errorMessage ?? 'Não foi possível carregar os layouts.',
        style: Theme.of(context).textTheme.bodySmall,
      );
    }
    if (filtered.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Text(
            state.status == LayoutsStatus.loading
                ? 'Carregando layouts…'
                : 'Nenhum layout encontrado',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = AppDimens.gridGap;
        final columns = constraints.maxWidth > 860
            ? 3
            : constraints.maxWidth > 560
            ? 2
            : 1;
        final cardWidth =
            (constraints.maxWidth - gap * (columns - 1)) / columns;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final layout in filtered)
              SizedBox(
                // O primeiro card é alvo do tour de primeiro uso.
                key: layout == filtered.first
                    ? TourTargets.firstLayoutCard
                    : null,
                width: cardWidth,
                child: LayoutCard(
                  layout: layout,
                  onApply: () => _cubit.apply(layout),
                  onEdit: () {
                    _layoutEditorCubit.loadForEdit(layout);
                    _navigationCubit.navigate(AppScreen.layoutEditor);
                  },
                  onToggleFavorite: () => _cubit.toggleFavorite(layout),
                  onDelete: layout.isPreset
                      ? null
                      : () => _cubit.delete(layout),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Seletor do monitor de destino ao aplicar layouts. Reage à conexão/
/// remoção de telas via [MonitorsCubit] e mostra o layout aplicado em
/// cada monitor, com opção de limpá-lo.
class _MonitorSelector extends StatelessWidget {
  _MonitorSelector({
    super.key,
    required this.cubit,
    required this.targetMonitorId,
  });

  final LayoutsCubit cubit;
  final int? targetMonitorId;

  final MonitorsCubit _monitorsCubit = getIt<MonitorsCubit>();
  final AppliedLayoutsCubit _appliedLayoutsCubit = getIt<AppliedLayoutsCubit>();

  /// Nome do layout aplicado no monitor, se houver.
  String? _appliedLayoutName(Monitor monitor, Map<String, int> applied) {
    final layoutId = applied[monitorKey(monitor)];
    if (layoutId == null) return null;
    return cubit.state.layouts
        .where((layout) => layout.id == layoutId)
        .firstOrNull
        ?.name;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return BlocBuilder<MonitorsCubit, MonitorsState>(
      bloc: _monitorsCubit,
      builder: (context, monitorsState) {
        return BlocBuilder<AppliedLayoutsCubit, Map<String, int>>(
          bloc: _appliedLayoutsCubit,
          builder: (context, applied) {
            final monitors = monitorsState.monitors;
            final selected = monitors
                .where((m) => m.id == targetMonitorId)
                .firstOrNull;
            final label = selected?.name ?? 'Automático';

            return PopupMenuButton<VoidCallback>(
              tooltip: 'Monitor de destino',
              color: colors.panel2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: colors.cardBorder),
              ),
              onSelected: (action) => action(),
              itemBuilder: (context) => [
                PopupMenuItem<VoidCallback>(
                  value: () => cubit.setTargetMonitor(null),
                  height: 34,
                  child: const Text(
                    'Automático (janela em foco)',
                    style: TextStyle(fontSize: 12.5),
                  ),
                ),
                for (final monitor in monitors)
                  PopupMenuItem<VoidCallback>(
                    value: () => cubit.setTargetMonitor(monitor.id),
                    height: 44,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                monitor.name,
                                style: const TextStyle(fontSize: 13),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (monitor.isPrimary) ...[
                              const SizedBox(width: 6),
                              Text(
                                '· principal',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: colors.text3,
                                ),
                              ),
                            ],
                          ],
                        ),
                        Text(
                          switch (_appliedLayoutName(monitor, applied)) {
                            final name? => 'Layout: $name',
                            null => 'Nenhum layout aplicado',
                          },
                          style: TextStyle(fontSize: 11, color: colors.text3),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                // Limpar o layout aplicado remove as zonas de encaixe
                // daquele monitor.
                for (final monitor in monitors)
                  if (applied.containsKey(monitorKey(monitor)))
                    PopupMenuItem<VoidCallback>(
                      value: () =>
                          _appliedLayoutsCubit.remove(monitorKey(monitor)),
                      height: 34,
                      child: Row(
                        children: [
                          MsIcon('close', size: 14, color: colors.text3),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'Limpar layout de ${monitor.name}',
                              style: const TextStyle(fontSize: 12.5),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
              ],
              child: Container(
                height: 34,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: colors.hover,
                  borderRadius: BorderRadius.circular(
                    AppDimens.radiusIconButton,
                  ),
                  border: Border.all(
                    color: selected != null ? colors.blue : colors.cardBorder,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    MsIcon(
                      'monitor',
                      size: 15,
                      color: selected != null ? colors.blue : colors.text3,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Aplicar em: $label',
                      style: TextStyle(fontSize: 12.5, color: colors.text),
                    ),
                    const SizedBox(width: 4),
                    MsIcon('unfold_more', size: 14, color: colors.text3),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
