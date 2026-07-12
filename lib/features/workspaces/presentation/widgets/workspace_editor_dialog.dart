import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/ms_icon.dart';
import '../../../layouts/domain/entities/layout.dart';
import '../../../layouts/presentation/cubits/layouts_cubit.dart';
import '../../../layouts/presentation/widgets/layout_preview.dart';
import '../../../windows/presentation/cubits/windows_cubit.dart';
import '../../domain/entities/workspace.dart';

/// Pares de gradiente disponíveis para o avatar do workspace.
const List<(String, String)> _gradients = [
  ('#0A84FF', '#40C8E0'),
  ('#FF375F', '#BF5AF2'),
  ('#FF9F0A', '#FF375F'),
  ('#30D158', '#40C8E0'),
  ('#BF5AF2', '#0A84FF'),
];

/// Dialog de criação/edição de workspace.
///
/// Apps são adicionados a partir dos aplicativos com janelas abertas
/// (estado atual do WindowsCubit).
class WorkspaceEditorDialog extends StatefulWidget {
  const WorkspaceEditorDialog({super.key, this.workspace});

  /// Null para criar um novo.
  final Workspace? workspace;

  static Future<Workspace?> show(BuildContext context, {Workspace? workspace}) {
    return showDialog<Workspace>(
      context: context,
      builder: (_) => WorkspaceEditorDialog(workspace: workspace),
    );
  }

  @override
  State<WorkspaceEditorDialog> createState() => _WorkspaceEditorDialogState();
}

class _WorkspaceEditorDialogState extends State<WorkspaceEditorDialog> {
  final LayoutsCubit _layoutsCubit = getIt<LayoutsCubit>();

  late final TextEditingController _nameController;
  late final TextEditingController _emojiController;
  late List<WorkspaceApp> _apps;
  late int _gradientIndex;
  int? _layoutId;

  List<Layout> get _layouts => _layoutsCubit.state.layouts;

  @override
  void initState() {
    super.initState();
    final workspace = widget.workspace;
    _nameController = TextEditingController(text: workspace?.name ?? '');
    _emojiController = TextEditingController(text: workspace?.emoji ?? '💻');
    _apps = [...?workspace?.apps];
    _layoutId = workspace?.layoutId;
    _gradientIndex = _gradients.indexWhere(
      (g) => g.$1 == workspace?.gradientStartHex,
    );
    if (_gradientIndex < 0) _gradientIndex = 0;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emojiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Dialog(
      backgroundColor: colors.panel,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusCardLarge),
        side: BorderSide(color: colors.cardBorder),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.workspace == null
                    ? 'Novo workspace'
                    : 'Editar workspace',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  SizedBox(
                    width: 64,
                    child: TextField(
                      controller: _emojiController,
                      textAlign: TextAlign.center,
                      maxLength: 2,
                      style: const TextStyle(fontSize: 20),
                      decoration: _decoration(
                        colors,
                        'Emoji',
                      ).copyWith(counterText: ''),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _nameController,
                      autofocus: true,
                      style: TextStyle(fontSize: 13.5, color: colors.text),
                      decoration: _decoration(colors, 'Nome'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text('COR', style: Theme.of(context).textTheme.labelSmall),
              const SizedBox(height: 8),
              Row(
                children: [
                  for (var i = 0; i < _gradients.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: InkWell(
                        onTap: () => setState(() => _gradientIndex = i),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                colorFromHex(_gradients[i].$1),
                                colorFromHex(_gradients[i].$2),
                              ],
                            ),
                            shape: BoxShape.circle,
                            border: _gradientIndex == i
                                ? Border.all(color: colors.text, width: 2)
                                : null,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              Text('LAYOUT', style: Theme.of(context).textTheme.labelSmall),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                initialValue: _layoutId,
                items: [
                  for (final layout in _layouts)
                    DropdownMenuItem(
                      value: layout.id,
                      child: Text(
                        layout.name,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                ],
                onChanged: (value) => setState(() => _layoutId = value),
                decoration: _decoration(colors, 'Layout aplicado ao ativar'),
                dropdownColor: colors.panel2,
                style: TextStyle(fontSize: 13, color: colors.text),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Text('APPS', style: Theme.of(context).textTheme.labelSmall),
                  const Spacer(),
                  _AddRunningAppButton(
                    alreadyAdded: _apps.map((a) => a.bundleId).toSet(),
                    onAdd: (bundleId, appName) => setState(
                      () => _apps = [
                        ..._apps,
                        WorkspaceApp(
                          bundleId: bundleId,
                          appName: appName,
                          sortOrder: _apps.length,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  if (_apps.isEmpty)
                    Text(
                      'A ordem dos apps define a região de cada um.',
                      style: TextStyle(fontSize: 11.5, color: colors.text3),
                    ),
                  for (var i = 0; i < _apps.length; i++)
                    Chip(
                      label: Text(
                        '${i + 1}. ${_apps[i].appName}',
                        style: TextStyle(fontSize: 11.5, color: colors.text2),
                      ),
                      backgroundColor: colors.hover,
                      side: BorderSide.none,
                      deleteIcon: MsIcon(
                        'close',
                        size: 13,
                        color: colors.text3,
                      ),
                      onDeleted: () =>
                          setState(() => _apps = [..._apps]..removeAt(i)),
                    ),
                ],
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
                  FilledButton(onPressed: _submit, child: const Text('Salvar')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    final base = widget.workspace ?? const Workspace(name: '');
    Navigator.of(context).pop(
      base.copyWith(
        name: _nameController.text.trim(),
        emoji: _emojiController.text.trim().isEmpty
            ? '💻'
            : _emojiController.text.trim(),
        gradientStartHex: _gradients[_gradientIndex].$1,
        gradientEndHex: _gradients[_gradientIndex].$2,
        layoutId: () => _layoutId,
        apps: [
          for (var i = 0; i < _apps.length; i++)
            WorkspaceApp(
              bundleId: _apps[i].bundleId,
              appName: _apps[i].appName,
              sortOrder: i,
            ),
        ],
      ),
    );
  }

  InputDecoration _decoration(FlowDeskColors colors, String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(fontSize: 11.5, color: colors.text3),
      isDense: true,
      filled: true,
      fillColor: colors.hover,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusIconButton),
        borderSide: BorderSide.none,
      ),
    );
  }
}

/// Popup com os apps atualmente em execução (com janelas abertas).
class _AddRunningAppButton extends StatelessWidget {
  _AddRunningAppButton({required this.alreadyAdded, required this.onAdd});

  final Set<String> alreadyAdded;
  final void Function(String bundleId, String appName) onAdd;

  final WindowsCubit _windowsCubit = getIt<WindowsCubit>();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final windows = _windowsCubit.state.windows;

    final runningApps = <String, String>{};
    for (final window in windows) {
      if (window.bundleId.isNotEmpty &&
          !alreadyAdded.contains(window.bundleId)) {
        runningApps[window.bundleId] = window.appName;
      }
    }

    return PopupMenuButton<String>(
      tooltip: 'Adicionar app em execução',
      color: colors.panel2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: colors.cardBorder),
      ),
      onSelected: (bundleId) => onAdd(bundleId, runningApps[bundleId]!),
      itemBuilder: (context) => [
        if (runningApps.isEmpty)
          const PopupMenuItem(
            enabled: false,
            child: Text(
              'Nenhum app em execução',
              style: TextStyle(fontSize: 12.5),
            ),
          ),
        for (final entry in runningApps.entries)
          PopupMenuItem(
            value: entry.key,
            height: 34,
            child: Text(entry.value, style: const TextStyle(fontSize: 13)),
          ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: colors.blueSoft,
          borderRadius: BorderRadius.circular(AppDimens.radiusIconButton),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            MsIcon('add', size: 14, color: colors.blue),
            const SizedBox(width: 4),
            Text(
              'Adicionar app',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
