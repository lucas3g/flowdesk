import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/ms_icon.dart';
import '../../domain/entities/permissions_status.dart';
import '../cubits/permissions_cubit.dart';
import '../cubits/permissions_state.dart';

/// Aviso exibido no topo do conteúdo enquanto a permissão de Acessibilidade
/// não foi concedida — sem ela o FlowDesk não consegue mover janelas.
class PermissionsBanner extends StatelessWidget {
  PermissionsBanner({super.key});

  final PermissionsCubit _cubit = getIt<PermissionsCubit>();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PermissionsCubit, PermissionsState>(
      bloc: _cubit,
      buildWhen: (previous, current) =>
          previous.needsAccessibility != current.needsAccessibility,
      builder: (context, state) {
        if (!state.needsAccessibility) return const SizedBox.shrink();

        final colors = context.colors;

        return Container(
          margin: const EdgeInsets.fromLTRB(20, 14, 20, 0),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: colors.orange.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppDimens.radiusCard),
            border: Border.all(color: colors.orange.withValues(alpha: 0.35)),
          ),
          child: Row(
            children: [
              MsIcon('accessibility_new', size: 20, color: colors.orange),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Permissão de Acessibilidade necessária',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    Text(
                      'O FlowDesk precisa dela para mover e redimensionar '
                      'janelas de outros aplicativos.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              TextButton(
                onPressed: _cubit.requestAccessibility,
                child: const Text('Permitir'),
              ),
              const SizedBox(width: 4),
              FilledButton(
                onPressed: () =>
                    _cubit.openSettings(PermissionType.accessibility),
                child: const Text('Abrir Ajustes'),
              ),
            ],
          ),
        );
      },
    );
  }
}
