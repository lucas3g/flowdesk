import 'package:flutter/material.dart';

import '../../features/layouts/presentation/cubits/layouts_cubit.dart';
import '../../features/workspaces/presentation/cubits/workspaces_cubit.dart';
import '../di/injection.dart';
import '../routing/app_screen.dart';
import '../routing/navigation_cubit.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import 'ms_icon.dart';

/// Abre a paleta de comandos (⌘K).
Future<void> showCommandPalette(BuildContext context) {
  return showDialog(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.3),
    builder: (_) => const _CommandPalette(),
  );
}

class _PaletteEntry {
  const _PaletteEntry({
    required this.group,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.action,
    this.shortcut,
  });

  final String group;
  final String icon;
  final String title;
  final String subtitle;
  final String? shortcut;
  final VoidCallback action;
}

class _CommandPalette extends StatefulWidget {
  const _CommandPalette();

  @override
  State<_CommandPalette> createState() => _CommandPaletteState();
}

class _CommandPaletteState extends State<_CommandPalette> {
  final LayoutsCubit _layoutsCubit = getIt<LayoutsCubit>();
  final WorkspacesCubit _workspacesCubit = getIt<WorkspacesCubit>();
  final NavigationCubit _navigationCubit = getIt<NavigationCubit>();

  String _query = '';

  List<_PaletteEntry> get _entries => [
    for (final layout in _layoutsCubit.state.layouts)
      _PaletteEntry(
        group: 'Layouts',
        icon: 'dashboard_customize',
        title: layout.name,
        subtitle: 'Aplicar layout',
        shortcut: layout.shortcut,
        action: () => _layoutsCubit.apply(layout),
      ),
    for (final workspace in _workspacesCubit.state.workspaces)
      _PaletteEntry(
        group: 'Workspaces',
        icon: 'workspaces',
        title: '${workspace.emoji} ${workspace.name}',
        subtitle: 'Ativar workspace',
        shortcut: workspace.shortcut,
        action: () => _workspacesCubit.apply(workspace),
      ),
    for (final screen in AppScreen.values)
      _PaletteEntry(
        group: 'Navegar',
        icon: screen.iconName,
        title: screen.label,
        subtitle: 'Abrir tela',
        action: () => _navigationCubit.navigate(screen),
      ),
  ];

  List<_PaletteEntry> get _filtered {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return _entries;
    return _entries
        .where((entry) => entry.title.toLowerCase().contains(query))
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final filtered = _filtered;

    return Dialog(
      alignment: const Alignment(0, -0.5),
      backgroundColor: colors.panel,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusCardLarge),
        side: BorderSide(color: colors.cardBorder),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 420),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
              child: TextField(
                autofocus: true,
                onChanged: (value) => setState(() => _query = value),
                onSubmitted: (_) {
                  if (filtered.isNotEmpty) _execute(filtered.first);
                },
                style: TextStyle(fontSize: 14, color: colors.text),
                decoration: InputDecoration(
                  hintText: 'Buscar ou executar…',
                  hintStyle: TextStyle(fontSize: 14, color: colors.text3),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 8, right: 6),
                    child: MsIcon('search', size: 17, color: colors.text3),
                  ),
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 0,
                    minHeight: 0,
                  ),
                  isDense: true,
                  filled: true,
                  fillColor: colors.hover,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      AppDimens.radiusButton,
                    ),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Divider(height: 1, color: colors.separator),
            Flexible(
              child: filtered.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(30),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Nenhum resultado',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tente outro termo',
                            style: TextStyle(
                              fontSize: 12,
                              color: colors.text3,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final entry = filtered[index];
                        final showHeader =
                            index == 0 ||
                            filtered[index - 1].group != entry.group;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (showHeader)
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  8,
                                  16,
                                  4,
                                ),
                                child: Text(
                                  entry.group.toUpperCase(),
                                  style: Theme.of(
                                    context,
                                  ).textTheme.labelSmall,
                                ),
                              ),
                            _PaletteRow(
                              entry: entry,
                              onTap: () => _execute(entry),
                            ),
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _execute(_PaletteEntry entry) {
    Navigator.of(context).pop();
    entry.action();
  }
}

class _PaletteRow extends StatelessWidget {
  const _PaletteRow({required this.entry, required this.onTap});

  final _PaletteEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return InkWell(
      onTap: onTap,
      hoverColor: colors.hover,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: colors.blueSoft,
                borderRadius: BorderRadius.circular(7),
              ),
              alignment: Alignment.center,
              child: MsIcon(entry.icon, size: 15, color: colors.blue),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.title,
                    style: Theme.of(context).textTheme.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    entry.subtitle,
                    style: TextStyle(fontSize: 11, color: colors.text3),
                  ),
                ],
              ),
            ),
            if (entry.shortcut != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: colors.cardBorder),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  entry.shortcut!,
                  style: TextStyle(fontSize: 10.5, color: colors.text3),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
