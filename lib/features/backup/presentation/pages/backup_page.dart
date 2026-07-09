import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/ms_icon.dart';
import '../cubits/backup_cubit.dart';

/// Tela de Backup: exportar e importar dados em JSON.
class BackupPage extends StatelessWidget {
  BackupPage({super.key});

  final BackupCubit _cubit = getIt<BackupCubit>();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return BlocListener<BackupCubit, BackupState>(
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
              width: 480,
            ),
          );
        _cubit.clearFeedback();
      },
      child: BlocBuilder<BackupCubit, BackupState>(
        bloc: _cubit,
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              vertical: AppDimens.pagePaddingVertical,
              horizontal: AppDimens.pagePaddingHorizontal,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Backup',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Leve seus layouts, workspaces, regras e preferências '
                      'para outro Mac.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 22),
                    _BackupCard(
                      icon: 'ios_share',
                      accent: colors.blue,
                      title: 'Exportar dados',
                      description:
                          'Gera um arquivo JSON com seus layouts (exceto '
                          'presets), workspaces, regras e preferências.',
                      buttonLabel: 'Exportar…',
                      onPressed: state.isBusy ? null : _cubit.exportToFile,
                    ),
                    const SizedBox(height: AppDimens.gridGap),
                    _BackupCard(
                      icon: 'file_download',
                      accent: colors.green,
                      title: 'Importar dados',
                      description:
                          'Adiciona os layouts, workspaces e regras de um '
                          'backup e aplica as preferências salvas.',
                      buttonLabel: 'Importar…',
                      onPressed: state.isBusy ? null : _cubit.importFromFile,
                    ),
                    const SizedBox(height: AppDimens.gridGap),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: colors.blueSoft,
                        borderRadius: BorderRadius.circular(
                          AppDimens.radiusCard,
                        ),
                      ),
                      child: Row(
                        children: [
                          MsIcon('info', size: 16, color: colors.blue),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Os vínculos entre workspaces e layouts são '
                              'preservados pelo nome do layout.',
                              style: TextStyle(
                                fontSize: 12,
                                color: colors.text2,
                              ),
                            ),
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
      ),
    );
  }
}

class _BackupCard extends StatelessWidget {
  const _BackupCard({
    required this.icon,
    required this.accent,
    required this.title,
    required this.description,
    required this.buttonLabel,
    required this.onPressed,
  });

  final String icon;
  final Color accent;
  final String title;
  final String description;
  final String buttonLabel;
  final VoidCallback? onPressed;

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
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: MsIcon(icon, size: 19, color: accent),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(fontSize: 11.5, color: colors.text3),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          FilledButton(
            onPressed: onPressed,
            style: FilledButton.styleFrom(backgroundColor: accent),
            child: Text(buttonLabel),
          ),
        ],
      ),
    );
  }
}
