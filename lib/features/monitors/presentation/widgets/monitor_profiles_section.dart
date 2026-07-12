import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/fd_switch.dart';
import '../../../../core/widgets/ms_icon.dart';
import '../../../layouts/presentation/cubits/layouts_cubit.dart';
import '../../../workspaces/presentation/cubits/workspaces_cubit.dart';
import '../cubits/monitor_profiles_cubit.dart';

/// Seção "Perfis por configuração" da tela de Monitores.
class MonitorProfilesSection extends StatelessWidget {
  MonitorProfilesSection({super.key});

  final MonitorProfilesCubit _cubit = getIt<MonitorProfilesCubit>();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return BlocListener<MonitorProfilesCubit, MonitorProfilesState>(
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
              width: 440,
            ),
          );
        _cubit.clearFeedback();
      },
      child: BlocBuilder<MonitorProfilesCubit, MonitorProfilesState>(
        bloc: _cubit,
        builder: (context, state) {
          final current = state.currentProfile;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Perfis por configuração',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        Text(
                          current != null
                              ? "Configuração atual: perfil '${current.name}'"
                              : 'A configuração atual não possui perfil.',
                          style: TextStyle(fontSize: 11.5, color: colors.text3),
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _openSaveDialog(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colors.text,
                      side: BorderSide(color: colors.cardBorder),
                      textStyle: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    icon: MsIcon('bookmark_add', size: 15, color: colors.text2),
                    label: const Text('Salvar configuração atual'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (state.profiles.isNotEmpty)
                Container(
                  decoration: BoxDecoration(
                    color: colors.card,
                    borderRadius: BorderRadius.circular(AppDimens.radiusCard),
                    border: Border.all(color: colors.cardBorder),
                  ),
                  child: Column(
                    children: [
                      for (var i = 0; i < state.profiles.length; i++) ...[
                        if (i > 0)
                          Divider(
                            height: 1,
                            indent: 14,
                            color: colors.separator,
                          ),
                        _ProfileRow(
                          cubit: _cubit,
                          index: i,
                          isCurrent:
                              state.profiles[i].fingerprint ==
                              state.currentFingerprint,
                        ),
                      ],
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _openSaveDialog(BuildContext context) async {
    final result = await _SaveProfileDialog.show(context);
    if (result == null) return;
    await _cubit.saveForCurrentSetup(
      name: result.name,
      workspaceId: result.workspaceId,
      layoutId: result.layoutId,
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({
    required this.cubit,
    required this.index,
    required this.isCurrent,
  });

  final MonitorProfilesCubit cubit;
  final int index;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final profile = cubit.state.profiles[index];

    final workspaces = getIt<WorkspacesCubit>().state.workspaces;
    final layouts = getIt<LayoutsCubit>().state.layouts;
    String targetName = '—';
    if (profile.workspaceId != null) {
      for (final workspace in workspaces) {
        if (workspace.id == profile.workspaceId) {
          targetName = 'workspace ${workspace.name}';
        }
      }
    } else if (profile.layoutId != null) {
      for (final layout in layouts) {
        if (layout.id == profile.layoutId) targetName = 'layout ${layout.name}';
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      child: Row(
        children: [
          MsIcon(
            'devices',
            size: 16,
            color: isCurrent ? colors.green : colors.text2,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      profile.name,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    if (isCurrent) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: colors.green.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'atual',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            color: colors.green,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  'Aplica $targetName automaticamente',
                  style: TextStyle(fontSize: 11, color: colors.text3),
                ),
              ],
            ),
          ),
          Tooltip(
            message: 'Aplicação automática',
            child: FdSwitch(
              value: profile.autoApply,
              onChanged: (value) => cubit.saveForCurrentSetup(
                name: profile.name,
                workspaceId: profile.workspaceId,
                layoutId: profile.layoutId,
                autoApply: value,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Tooltip(
            message: 'Excluir perfil',
            child: InkWell(
              onTap: () => cubit.delete(profile),
              borderRadius: BorderRadius.circular(7),
              hoverColor: colors.hover,
              child: SizedBox(
                width: 30,
                height: 30,
                child: Center(
                  child: MsIcon('delete', size: 15, color: colors.text3),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SaveProfileResult {
  const _SaveProfileResult(this.name, this.workspaceId, this.layoutId);

  final String name;
  final int? workspaceId;
  final int? layoutId;
}

/// Dialog: nome do perfil + workspace ou layout a aplicar.
class _SaveProfileDialog extends StatefulWidget {
  const _SaveProfileDialog();

  static Future<_SaveProfileResult?> show(BuildContext context) {
    return showDialog<_SaveProfileResult>(
      context: context,
      builder: (_) => const _SaveProfileDialog(),
    );
  }

  @override
  State<_SaveProfileDialog> createState() => _SaveProfileDialogState();
}

class _SaveProfileDialogState extends State<_SaveProfileDialog> {
  final TextEditingController _nameController = TextEditingController();

  /// `w:id` para workspace, `l:id` para layout.
  String? _target;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final workspaces = getIt<WorkspacesCubit>().state.workspaces;
    final layouts = getIt<LayoutsCubit>().state.layouts;

    return Dialog(
      backgroundColor: colors.panel,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusCardLarge),
        side: BorderSide(color: colors.cardBorder),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Perfil desta configuração',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'Ao detectar estes monitores, o FlowDesk aplica o alvo '
                'escolhido automaticamente.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nameController,
                autofocus: true,
                style: TextStyle(fontSize: 13.5, color: colors.text),
                decoration: InputDecoration(
                  labelText: 'Nome (ex.: Escritório, Notebook)',
                  labelStyle: TextStyle(fontSize: 11.5, color: colors.text3),
                  isDense: true,
                  filled: true,
                  fillColor: colors.hover,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      AppDimens.radiusIconButton,
                    ),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _target,
                items: [
                  for (final workspace in workspaces)
                    DropdownMenuItem(
                      value: 'w:${workspace.id}',
                      child: Text(
                        '${workspace.emoji} ${workspace.name} (workspace)',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  for (final layout in layouts)
                    DropdownMenuItem(
                      value: 'l:${layout.id}',
                      child: Text(
                        '${layout.name} (layout)',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                ],
                onChanged: (value) => setState(() => _target = value),
                decoration: InputDecoration(
                  labelText: 'Aplicar automaticamente',
                  labelStyle: TextStyle(fontSize: 11.5, color: colors.text3),
                  isDense: true,
                  filled: true,
                  fillColor: colors.hover,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      AppDimens.radiusIconButton,
                    ),
                    borderSide: BorderSide.none,
                  ),
                ),
                dropdownColor: colors.panel2,
                style: TextStyle(fontSize: 13, color: colors.text),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _target == null
                        ? null
                        : () {
                            final parts = _target!.split(':');
                            final id = int.parse(parts[1]);
                            Navigator.of(context).pop(
                              _SaveProfileResult(
                                _nameController.text.trim(),
                                parts[0] == 'w' ? id : null,
                                parts[0] == 'l' ? id : null,
                              ),
                            );
                          },
                    child: const Text('Salvar perfil'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
