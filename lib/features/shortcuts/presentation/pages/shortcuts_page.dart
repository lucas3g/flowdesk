import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/ms_icon.dart';
import '../../../layouts/presentation/cubits/layouts_cubit.dart';
import '../../../layouts/presentation/cubits/layouts_state.dart';
import '../../../workspaces/presentation/cubits/workspaces_cubit.dart';
import '../../../workspaces/presentation/cubits/workspaces_state.dart';
import '../../domain/entities/hotkey_combo.dart';

/// Tela de Atalhos: combos de layouts e workspaces (editáveis) e atalhos
/// gerais do app.
class ShortcutsPage extends StatefulWidget {
  const ShortcutsPage({super.key});

  @override
  State<ShortcutsPage> createState() => _ShortcutsPageState();
}

class _ShortcutsPageState extends State<ShortcutsPage> {
  final LayoutsCubit _layoutsCubit = getIt<LayoutsCubit>();
  final WorkspacesCubit _workspacesCubit = getIt<WorkspacesCubit>();

  @override
  void initState() {
    super.initState();
    _layoutsCubit.load();
    _workspacesCubit.load();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LayoutsCubit, LayoutsState>(
      bloc: _layoutsCubit,
      builder: (context, layoutsState) {
        return BlocBuilder<WorkspacesCubit, WorkspacesState>(
          bloc: _workspacesCubit,
          builder: (context, workspacesState) {
            final usedCombos = <String>{
              for (final layout in layoutsState.layouts)
                if (layout.shortcut != null) layout.shortcut!,
              for (final workspace in workspacesState.workspaces)
                if (workspace.shortcut != null) workspace.shortcut!,
            };

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                vertical: AppDimens.pagePaddingVertical,
                horizontal: AppDimens.pagePaddingHorizontal,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Atalhos',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Atalhos globais — funcionam mesmo com o FlowDesk '
                        'em segundo plano.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 22),
                      _ShortcutsGroup(
                        title: 'LAYOUTS',
                        children: [
                          for (final layout in layoutsState.layouts)
                            _ShortcutRow(
                              label: layout.name,
                              combo: layout.shortcut,
                              options: HotkeyCombo.layoutOptions()
                                  .where(
                                    (option) =>
                                        option == layout.shortcut ||
                                        !usedCombos.contains(option),
                                  )
                                  .toList(),
                              onChanged: (combo) =>
                                  _layoutsCubit.setShortcut(layout, combo),
                            ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      _ShortcutsGroup(
                        title: 'WORKSPACES',
                        children: [
                          for (final workspace in workspacesState.workspaces)
                            _ShortcutRow(
                              label: '${workspace.emoji} ${workspace.name}',
                              combo: workspace.shortcut,
                              options: HotkeyCombo.workspaceOptions()
                                  .where(
                                    (option) =>
                                        option == workspace.shortcut ||
                                        !usedCombos.contains(option),
                                  )
                                  .toList(),
                              onChanged: (combo) => _workspacesCubit.save(
                                workspace.copyWith(shortcut: () => combo),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      _ShortcutsGroup(
                        title: 'GERAL',
                        children: const [
                          _FixedShortcutRow(
                            label: 'Paleta de comandos',
                            combo: '⌘K',
                          ),
                          _FixedShortcutRow(label: 'Preferências', combo: '⌘,'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _ShortcutsGroup extends StatelessWidget {
  const _ShortcutsGroup({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(title, style: Theme.of(context).textTheme.labelSmall),
        ),
        Container(
          decoration: BoxDecoration(
            color: colors.card,
            borderRadius: BorderRadius.circular(AppDimens.radiusCard),
            border: Border.all(color: colors.cardBorder),
          ),
          child: Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0)
                  Divider(height: 1, indent: 14, color: colors.separator),
                children[i],
              ],
              if (children.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Text(
                    'Nada por aqui ainda.',
                    style: TextStyle(fontSize: 12, color: colors.text3),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Linha com seletor de combo (inclui "Sem atalho").
class _ShortcutRow extends StatelessWidget {
  const _ShortcutRow({
    required this.label,
    required this.combo,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final String? combo;
  final List<String> options;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          PopupMenuButton<String>(
            initialValue: combo,
            onSelected: (value) => onChanged(value.isEmpty ? null : value),
            color: colors.panel2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: colors.cardBorder),
            ),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: '',
                height: 32,
                child: Text('Sem atalho', style: TextStyle(fontSize: 12.5)),
              ),
              for (final option in options)
                PopupMenuItem(
                  value: option,
                  height: 32,
                  child: Text(option, style: const TextStyle(fontSize: 13)),
                ),
            ],
            child: _ComboChip(combo: combo),
          ),
        ],
      ),
    );
  }
}

class _FixedShortcutRow extends StatelessWidget {
  const _FixedShortcutRow({required this.label, required this.combo});

  final String label;
  final String combo;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          _ComboChip(combo: combo),
        ],
      ),
    );
  }
}

class _ComboChip extends StatelessWidget {
  const _ComboChip({required this.combo});

  final String? combo;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        border: Border.all(color: colors.cardBorder),
        borderRadius: BorderRadius.circular(5),
        color: combo == null ? Colors.transparent : colors.hover,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            combo ?? 'Definir',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: combo == null ? colors.text3 : colors.text,
            ),
          ),
          const SizedBox(width: 4),
          MsIcon('unfold_more', size: 12, color: colors.text3),
        ],
      ),
    );
  }
}
