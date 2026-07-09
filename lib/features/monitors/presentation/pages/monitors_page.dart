import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/ms_icon.dart';
import '../cubits/monitors_cubit.dart';
import '../cubits/monitors_state.dart';
import '../widgets/monitor_detail_card.dart';
import '../widgets/monitor_profiles_section.dart';
import '../widgets/monitor_stage.dart';

/// Tela de Monitores: visualização em escala + cards de especificações.
class MonitorsPage extends StatelessWidget {
  MonitorsPage({super.key});

  final MonitorsCubit _cubit = getIt<MonitorsCubit>();

  static final NumberFormat _pxFormat = NumberFormat.decimalPattern('pt_BR');

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return BlocBuilder<MonitorsCubit, MonitorsState>(
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
                  const SizedBox(height: 20),
                  if (state.status == MonitorsStatus.error)
                    _ErrorCard(message: state.errorMessage),
                  MonitorStage(
                    monitors: state.monitors,
                    selectedId: state.selectedId,
                    onSelect: _cubit.select,
                  ),
                  const SizedBox(height: AppDimens.gridGap),
                  _buildDetailGrid(state),
                  const SizedBox(height: 26),
                  MonitorProfilesSection(),
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
    MonitorsState state,
  ) {
    final count = state.monitors.length;
    final subtitle = count == 0
        ? 'Nenhum monitor detectado'
        : '$count ${count == 1 ? 'monitor conectado' : 'monitores conectados'}'
              ' · ${_pxFormat.format(state.totalPixelWidth)} px de largura total';

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Monitores', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 2),
              Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
        OutlinedButton.icon(
          onPressed: _cubit.refresh,
          style: OutlinedButton.styleFrom(
            foregroundColor: colors.text,
            side: BorderSide(color: colors.cardBorder),
            textStyle: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusButton),
            ),
          ),
          icon: MsIcon('refresh', size: 15, color: colors.text2),
          label: const Text('Detectar novamente'),
        ),
      ],
    );
  }

  Widget _buildDetailGrid(MonitorsState state) {
    if (state.monitors.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = AppDimens.gridGap;
        final columns = constraints.maxWidth > 900
            ? 3
            : constraints.maxWidth > 600
            ? 2
            : 1;
        final cardWidth =
            (constraints.maxWidth - gap * (columns - 1)) / columns;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (var i = 0; i < state.monitors.length; i++)
              SizedBox(
                width: cardWidth,
                child: MonitorDetailCard(
                  monitor: state.monitors[i],
                  accent: monitorAccent(context.colors, i),
                  selected: state.monitors[i].id == state.selectedId,
                  onTap: () => _cubit.select(state.monitors[i].id),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppDimens.gridGap),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        border: Border.all(color: colors.red.withValues(alpha: 0.3)),
      ),
      child: Text(
        message ?? 'Não foi possível consultar os monitores.',
        style: TextStyle(fontSize: 12.5, color: colors.text2),
      ),
    );
  }
}
