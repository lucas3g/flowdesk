import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/ms_icon.dart';
import '../../../../core/di/injection.dart';
import '../../../layouts/domain/entities/layout.dart';
import '../../../layouts/presentation/widgets/layout_preview.dart';
import '../../../windows/presentation/cubits/windows_cubit.dart';
import '../cubits/layout_editor_state.dart';

/// Painel lateral do editor: propriedades da região selecionada e presets.
class RegionInspector extends StatelessWidget {
  const RegionInspector({
    super.key,
    required this.state,
    required this.onRename,
    required this.onSetFrame,
    required this.onSetColor,
    required this.onSetApp,
    required this.onDelete,
    required this.onApplyPreset,
  });

  final LayoutEditorState state;
  final ValueChanged<String> onRename;
  final void Function({double? x, double? y, double? width, double? height})
  onSetFrame;
  final ValueChanged<String> onSetColor;

  /// Associa um app à região (nulls removem a associação); [windowTitle]
  /// identifica a instância quando o app tem várias janelas abertas.
  final void Function({String? bundleId, String? appName, String? windowTitle})
  onSetApp;
  final VoidCallback onDelete;
  final ValueChanged<RegionPreset> onApplyPreset;

  static const List<String> _palette = [
    '#0A84FF',
    '#40C8E0',
    '#BF5AF2',
    '#30D158',
    '#FF9F0A',
    '#FF375F',
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final region = state.selected;

    return Container(
      width: 260,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(AppDimens.radiusCardLarge),
        border: Border.all(color: colors.cardBorder),
      ),
      child: region == null
          ? _EmptyInspector(colors: colors)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('REGIÃO', style: Theme.of(context).textTheme.labelSmall),
                const SizedBox(height: 10),
                TextField(
                  key: ValueKey('name-${state.selectedIndex}-${region.id}'),
                  controller: TextEditingController(text: region.name),
                  onSubmitted: onRename,
                  style: TextStyle(fontSize: 13, color: colors.text),
                  decoration: _fieldDecoration(colors, 'Nome'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _NumberField(
                        label: 'X',
                        value: region.x,
                        onChanged: (v) => onSetFrame(x: v),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _NumberField(
                        label: 'Y',
                        value: region.y,
                        onChanged: (v) => onSetFrame(y: v),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _NumberField(
                        label: 'Largura',
                        value: region.width,
                        onChanged: (v) => onSetFrame(width: v),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _NumberField(
                        label: 'Altura',
                        value: region.height,
                        onChanged: (v) => onSetFrame(height: v),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text('COR', style: Theme.of(context).textTheme.labelSmall),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final hex in _palette)
                      InkWell(
                        onTap: () => onSetColor(hex),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: colorFromHex(hex),
                            shape: BoxShape.circle,
                            border: region.colorHex == hex
                                ? Border.all(color: colors.text, width: 2)
                                : null,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  'APP ASSOCIADO',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                const SizedBox(height: 8),
                _RegionAppSelector(region: region, onSetApp: onSetApp),
                const SizedBox(height: 18),
                _PresetsSection(onApplyPreset: onApplyPreset),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: onDelete,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colors.red,
                      side: BorderSide(
                        color: colors.red.withValues(alpha: 0.4),
                      ),
                    ),
                    icon: MsIcon('delete', size: 15, color: colors.red),
                    label: const Text('Excluir região'),
                  ),
                ),
              ],
            ),
    );
  }

  InputDecoration _fieldDecoration(FlowDeskColors colors, String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(fontSize: 11.5, color: colors.text3),
      isDense: true,
      filled: true,
      fillColor: colors.hover,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusIconButton),
        borderSide: BorderSide.none,
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return TextField(
      key: ValueKey('$label-$value'),
      controller: TextEditingController(
        text: value.toStringAsFixed(value == value.roundToDouble() ? 0 : 2),
      ),
      onSubmitted: (text) {
        final parsed = double.tryParse(text.replaceAll(',', '.'));
        if (parsed != null) onChanged(parsed);
      },
      style: TextStyle(fontSize: 12.5, color: colors.text),
      decoration: InputDecoration(
        labelText: '$label (%)',
        labelStyle: TextStyle(fontSize: 11, color: colors.text3),
        isDense: true,
        filled: true,
        fillColor: colors.hover,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusIconButton),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

/// Uma opção do seletor: app inteiro (windowTitle null) ou uma janela
/// específica quando o app tem várias instâncias abertas.
typedef _AppOption = ({
  String bundleId,
  String appName,
  String? windowTitle,
  String label,
  Uint8List? icon,
  bool isInstance,
});

/// Seletor do app que ocupa a região ao aplicar o layout: lista os apps
/// em execução com seus ícones — apps com várias janelas ganham uma
/// entrada por instância, identificada pelo título da janela —, mantém a
/// associação atual mesmo se o app não estiver aberto, e permite remover.
class _RegionAppSelector extends StatelessWidget {
  const _RegionAppSelector({required this.region, required this.onSetApp});

  final LayoutRegion region;
  final void Function({String? bundleId, String? appName, String? windowTitle})
  onSetApp;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final options = _buildOptions();

    final selectedIndex = options.indexWhere(
      (option) =>
          option.bundleId == region.appBundleId &&
          (option.windowTitle ?? '') == (region.appWindowTitle ?? ''),
    );
    final currentIcon = region.hasApp
        ? options
              .where((option) => option.bundleId == region.appBundleId)
              .firstOrNull
              ?.icon
        : null;

    return PopupMenuButton<int>(
      tooltip: 'Escolher app',
      initialValue: selectedIndex >= 0 ? selectedIndex : -1,
      color: colors.panel2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: colors.cardBorder),
      ),
      onSelected: (index) {
        if (index < 0) {
          onSetApp(bundleId: null, appName: null, windowTitle: null);
          return;
        }
        final option = options[index];
        onSetApp(
          bundleId: option.bundleId,
          appName: option.appName,
          windowTitle: option.windowTitle,
        );
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: -1,
          height: 34,
          child: Row(
            children: [
              MsIcon('block', size: 16, color: colors.text3),
              const SizedBox(width: 10),
              const Text(
                'Nenhum (por ordem)',
                style: TextStyle(fontSize: 12.5),
              ),
            ],
          ),
        ),
        for (final (index, option) in options.indexed)
          PopupMenuItem(
            value: index,
            height: 34,
            child: Row(
              children: [
                if (option.isInstance)
                  // Instância recuada sob o item do app.
                  Padding(
                    padding: const EdgeInsets.only(left: 14),
                    child: MsIcon(
                      'subdirectory_arrow_right',
                      size: 14,
                      color: colors.text3,
                    ),
                  )
                else
                  _AppIcon(icon: option.icon, size: 20),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    option.label,
                    style: TextStyle(
                      fontSize: option.isInstance ? 12 : 13,
                      color: option.isInstance ? colors.text2 : colors.text,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
      ],
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: colors.hover,
          borderRadius: BorderRadius.circular(AppDimens.radiusIconButton),
          border: Border.all(
            color: region.hasApp ? colors.blue : colors.cardBorder,
          ),
        ),
        child: Row(
          children: [
            if (region.hasApp)
              _AppIcon(icon: currentIcon, size: 18)
            else
              MsIcon('block', size: 15, color: colors.text3),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                region.hasApp ? _currentLabel() : 'Nenhum (por ordem)',
                style: TextStyle(
                  fontSize: 12.5,
                  color: region.hasApp ? colors.text : colors.text3,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            MsIcon('unfold_more', size: 14, color: colors.text3),
          ],
        ),
      ),
    );
  }

  String _currentLabel() {
    final name = region.appName ?? region.appBundleId!;
    return region.hasWindowTitle ? '$name — ${region.appWindowTitle}' : name;
  }

  /// Um item por app; apps com mais de uma janela ganham, abaixo do item
  /// do app ("qualquer janela"), um item por instância com o título dela.
  List<_AppOption> _buildOptions() {
    final windowsByApp = <String, (String, Uint8List?, List<String>)>{};
    for (final window in getIt<WindowsCubit>().state.windows) {
      if (window.bundleId.isEmpty) continue;
      final entry = windowsByApp[window.bundleId];
      windowsByApp[window.bundleId] = (
        window.appName,
        entry?.$2 ?? window.icon,
        [...?entry?.$3, window.title],
      );
    }
    // Associação atual sempre aparece, mesmo com o app fechado.
    if (region.hasApp) {
      windowsByApp.putIfAbsent(
        region.appBundleId!,
        () => (region.appName ?? region.appBundleId!, null, const []),
      );
      if (region.hasWindowTitle &&
          !windowsByApp[region.appBundleId!]!.$3.contains(
            region.appWindowTitle,
          )) {
        final entry = windowsByApp[region.appBundleId!]!;
        windowsByApp[region.appBundleId!] = (
          entry.$1,
          entry.$2,
          [...entry.$3, region.appWindowTitle!],
        );
      }
    }

    final options = <_AppOption>[];
    for (final entry in windowsByApp.entries) {
      final (appName, icon, titles) = entry.value;
      options.add((
        bundleId: entry.key,
        appName: appName,
        windowTitle: null,
        label: appName,
        icon: icon,
        isInstance: false,
      ));
      // Títulos não vazios distinguem as instâncias; com uma janela só,
      // o item do app basta.
      final distinctTitles = titles.where((t) => t.isNotEmpty).toSet();
      if (titles.length > 1 && distinctTitles.isNotEmpty) {
        for (final title in distinctTitles) {
          options.add((
            bundleId: entry.key,
            appName: appName,
            windowTitle: title,
            label: title,
            icon: icon,
            isInstance: true,
          ));
        }
      }
    }
    return options;
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
          child: MsIcon('apps', size: size - 4, color: colors.text2),
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

class _PresetsSection extends StatelessWidget {
  const _PresetsSection({required this.onApplyPreset});

  final ValueChanged<RegionPreset> onApplyPreset;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('PRESETS', style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final preset in RegionPreset.values)
              Tooltip(
                message: preset.label,
                child: InkWell(
                  onTap: () => onApplyPreset(preset),
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    width: 52,
                    height: 34,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: colors.hover,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: colors.cardBorder),
                    ),
                    child: Align(
                      alignment: Alignment(
                        preset.width >= 100
                            ? 0
                            : (preset.x / (100 - preset.width)) * 2 - 1,
                        preset.height >= 100
                            ? 0
                            : (preset.y / (100 - preset.height)) * 2 - 1,
                      ),
                      child: FractionallySizedBox(
                        widthFactor: preset.width / 100,
                        heightFactor: preset.height / 100,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: colors.blue.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _EmptyInspector extends StatelessWidget {
  const _EmptyInspector({required this.colors});

  final FlowDeskColors colors;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          MsIcon('highlight_alt', size: 28, color: colors.text3),
          const SizedBox(height: 10),
          Text(
            'Nenhuma região selecionada',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 4),
          Text(
            'Clique em uma região para editar,\nou arraste no canvas para criar.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11.5, color: colors.text3),
          ),
        ],
      ),
    );
  }
}
