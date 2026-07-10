import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/ms_icon.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../windows/domain/entities/managed_window.dart';
import '../../../windows/presentation/cubits/windows_cubit.dart';
import '../../../windows/presentation/cubits/windows_state.dart';
import '../../domain/entities/app_settings.dart';

/// App em execução candidato à exclusão: ícone e as instâncias abertas,
/// exibidas quando há mais de uma janela.
typedef _RunningApp = ({
  String bundleId,
  String appName,
  Uint8List? icon,
  List<ManagedWindow> instances,
});

/// Agrupa as janelas por app (ícone + instâncias).
Map<String, _RunningApp> _runningAppsById(List<ManagedWindow> windows) {
  final apps = <String, _RunningApp>{};
  for (final window in windows) {
    if (window.bundleId.isEmpty) continue;
    final entry = apps[window.bundleId];
    apps[window.bundleId] = (
      bundleId: window.bundleId,
      appName: entry?.appName ?? window.appName,
      icon: entry?.icon ?? window.icon,
      instances: [...?entry?.instances, window],
    );
  }
  return apps;
}

/// Rótulo da instância: o título da janela ou, quando vazio, a posição na
/// lista com o tamanho ("Janela 2 · 1280×720") para poder distingui-la.
String _instanceLabel(ManagedWindow window, int index) {
  if (window.title.isNotEmpty) return window.title;
  final size = '${window.width.round()}×${window.height.round()}';
  return 'Janela ${index + 1} · $size';
}

/// Linha de configurações que gerencia os apps excluídos do encaixe ao
/// arrastar: botão para adicionar (a partir dos apps em execução) e chips
/// com remoção individual.
class SnapExcludedAppsRow extends StatelessWidget {
  const SnapExcludedAppsRow({
    super.key,
    required this.apps,
    required this.onChanged,
  });

  final List<SnapExcludedApp> apps;
  final ValueChanged<List<SnapExcludedApp>> onChanged;

  Future<void> _addApp(BuildContext context) async {
    final chosen = await _SnapExcludedAppPickerDialog.show(context, apps);
    if (chosen != null) onChanged([...apps, chosen]);
  }

  void _removeApp(SnapExcludedApp app) {
    onChanged([...apps]..remove(app));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final running = _runningAppsById(getIt<WindowsCubit>().state.windows);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: colors.hover,
                  borderRadius: BorderRadius.circular(7),
                ),
                alignment: Alignment.center,
                child: MsIcon('block', size: 15, color: colors.text2),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Apps sem encaixe',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      'Arrastar estes apps não mostra zonas nem redimensiona',
                      style: TextStyle(fontSize: 11.5, color: colors.text3),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () => _addApp(context),
                borderRadius: BorderRadius.circular(AppDimens.radiusIconButton),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: colors.hover,
                    borderRadius: BorderRadius.circular(
                      AppDimens.radiusIconButton,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      MsIcon('add', size: 14, color: colors.text2),
                      const SizedBox(width: 4),
                      Text(
                        'Adicionar',
                        style: TextStyle(fontSize: 12.5, color: colors.text2),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (apps.isNotEmpty) ...[
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 40),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final app in apps)
                    Container(
                      padding: const EdgeInsets.only(
                        left: 8,
                        right: 6,
                        top: 4,
                        bottom: 4,
                      ),
                      decoration: BoxDecoration(
                        color: colors.hover,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: colors.cardBorder),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _AppIcon(
                            icon: running[app.bundleId]?.icon,
                            size: 15,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            app.windowId == null
                                ? (app.appName.isEmpty
                                      ? app.bundleId
                                      : app.appName)
                                : '${app.appName} — '
                                      '${app.windowTitle ?? 'janela'}',
                            style: TextStyle(
                              fontSize: 12,
                              color: colors.text2,
                            ),
                          ),
                          const SizedBox(width: 4),
                          InkWell(
                            onTap: () => _removeApp(app),
                            borderRadius: BorderRadius.circular(999),
                            child: MsIcon(
                              'close',
                              size: 13,
                              color: colors.text3,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Dialog que lista os apps em execução (fora da lista atual) com ícone e,
/// quando há mais de uma janela aberta, os títulos das instâncias.
class _SnapExcludedAppPickerDialog extends StatefulWidget {
  const _SnapExcludedAppPickerDialog({required this.excluded});

  final List<SnapExcludedApp> excluded;

  static Future<SnapExcludedApp?> show(
    BuildContext context,
    List<SnapExcludedApp> excluded,
  ) {
    return showDialog<SnapExcludedApp>(
      context: context,
      builder: (_) => _SnapExcludedAppPickerDialog(excluded: excluded),
    );
  }

  @override
  State<_SnapExcludedAppPickerDialog> createState() =>
      _SnapExcludedAppPickerDialogState();
}

class _SnapExcludedAppPickerDialogState
    extends State<_SnapExcludedAppPickerDialog> {
  final WindowsCubit _windowsCubit = getIt<WindowsCubit>();

  @override
  void initState() {
    super.initState();
    // Garante janelas (e títulos) atualizados ao abrir o seletor.
    _windowsCubit.refresh();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WindowsCubit, WindowsState>(
      bloc: _windowsCubit,
      builder: (context, state) => _buildDialog(context, state.windows),
    );
  }

  Widget _buildDialog(BuildContext context, List<ManagedWindow> windows) {
    final colors = context.colors;

    // Apps já excluídos por inteiro saem da lista; exclusões por instância
    // apenas escondem a instância correspondente.
    final excludedApps = {
      for (final app in widget.excluded)
        if (app.windowId == null) app.bundleId,
    };
    final excludedWindowIds = {
      for (final app in widget.excluded)
        if (app.windowId != null) app.windowId,
    };
    final candidates =
        _runningAppsById(windows).values
            .where((app) => !excludedApps.contains(app.bundleId))
            .toList()
          ..sort(
            (a, b) =>
                a.appName.toLowerCase().compareTo(b.appName.toLowerCase()),
          );

    return Dialog(
      backgroundColor: colors.panel,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusCardLarge),
        side: BorderSide(color: colors.cardBorder),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 480),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Excluir app do encaixe',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Clique no app para excluir todas as janelas, '
                    'ou em uma instância para excluir só ela',
                    style: TextStyle(fontSize: 11.5, color: colors.text3),
                  ),
                ],
              ),
            ),
            if (candidates.isEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
                child: Text(
                  'Nenhum app em execução disponível.',
                  style: TextStyle(fontSize: 12.5, color: colors.text3),
                ),
              )
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
                  itemCount: candidates.length,
                  itemBuilder: (context, index) {
                    final app = candidates[index];
                    // Com mais de uma janela, cada instância (fora da lista
                    // atual) vira um item clicável para excluir só ela —
                    // identificada pelo id único da janela.
                    final instances = app.instances.length > 1
                        ? app.instances
                              .where(
                                (window) =>
                                    !excludedWindowIds.contains(window.id),
                              )
                              .toList()
                        : const <ManagedWindow>[];

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Item do app: exclui todas as instâncias.
                        InkWell(
                          onTap: () => Navigator.of(context).pop(
                            SnapExcludedApp(
                              bundleId: app.bundleId,
                              appName: app.appName,
                            ),
                          ),
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            child: Row(
                              children: [
                                _AppIcon(icon: app.icon, size: 20),
                                const SizedBox(width: 10),
                                Flexible(
                                  child: Text(
                                    app.appName,
                                    style: const TextStyle(fontSize: 13),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (app.instances.length > 1) ...[
                                  const SizedBox(width: 6),
                                  Text(
                                    'todas as '
                                    '${app.instances.length} janelas',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: colors.text3,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        // Itens por instância: excluem só aquela janela.
                        for (final (i, window) in instances.indexed)
                          InkWell(
                            onTap: () => Navigator.of(context).pop(
                              SnapExcludedApp(
                                bundleId: app.bundleId,
                                appName: app.appName,
                                windowId: window.id,
                                windowTitle: _instanceLabel(window, i),
                              ),
                            ),
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                34,
                                4,
                                10,
                                4,
                              ),
                              child: Row(
                                children: [
                                  MsIcon(
                                    'subdirectory_arrow_right',
                                    size: 13,
                                    color: colors.text3,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      _instanceLabel(window, i),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: colors.text2,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
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
}

/// Ícone do app vindo do sistema, com fallback genérico.
class _AppIcon extends StatelessWidget {
  const _AppIcon({required this.icon, required this.size});

  final Uint8List? icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    if (icon == null) {
      return SizedBox(
        width: size,
        height: size,
        child: Center(
          child: MsIcon('apps', size: size - 3, color: colors.text2),
        ),
      );
    }
    return Image.memory(
      icon!,
      width: size,
      height: size,
      gaplessPlayback: true,
    );
  }
}
