import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/fd_switch.dart';
import '../../../../core/widgets/ms_icon.dart';

/// Card de grupo de configurações com título em caixa alta e linhas
/// separadas por divisores, como no design.
class SettingsGroup extends StatelessWidget {
  const SettingsGroup({super.key, required this.title, required this.children});

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
                  Divider(height: 1, indent: 52, color: colors.separator),
                children[i],
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Linha base: ícone em tile, título/subtítulo e um controle à direita.
class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.label,
    required this.trailing,
    this.subtitle,
  });

  final String icon;
  final String label;
  final String? subtitle;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: colors.hover,
              borderRadius: BorderRadius.circular(7),
            ),
            alignment: Alignment.center,
            child: MsIcon(icon, size: 15, color: colors.text2),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.bodyMedium),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: TextStyle(fontSize: 11.5, color: colors.text3),
                  ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}

/// Linha com toggle estilo iOS.
class SettingsToggleRow extends StatelessWidget {
  const SettingsToggleRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
    this.subtitle,
  });

  final String icon;
  final String label;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return _SettingsRow(
      icon: icon,
      label: label,
      subtitle: subtitle,
      trailing: FdSwitch(value: value, onChanged: onChanged),
    );
  }
}

/// Linha com seletor de valor (menu suspenso), ex.: tema, idioma, espaçamentos.
class SettingsValueRow<T> extends StatelessWidget {
  const SettingsValueRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    this.subtitle,
  });

  final String icon;
  final String label;
  final String? subtitle;
  final T value;

  /// Valor → rótulo exibido.
  final Map<T, String> options;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return _SettingsRow(
      icon: icon,
      label: label,
      subtitle: subtitle,
      trailing: PopupMenuButton<T>(
        initialValue: value,
        onSelected: onChanged,
        color: colors.panel2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: colors.cardBorder),
        ),
        itemBuilder: (context) => [
          for (final entry in options.entries)
            PopupMenuItem<T>(
              value: entry.key,
              height: 36,
              child: Text(entry.value, style: const TextStyle(fontSize: 13)),
            ),
        ],
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: colors.hover,
            borderRadius: BorderRadius.circular(AppDimens.radiusIconButton),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                options[value] ?? '$value',
                style: TextStyle(fontSize: 12.5, color: colors.text2),
              ),
              const SizedBox(width: 6),
              MsIcon('unfold_more', size: 14, color: colors.text3),
            ],
          ),
        ),
      ),
    );
  }
}
