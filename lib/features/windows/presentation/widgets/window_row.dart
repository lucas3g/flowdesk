import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/ms_icon.dart';
import '../../domain/entities/managed_window.dart';

/// Linha de uma janela: ícone do app, título, app · dimensões e ações.
class WindowRow extends StatelessWidget {
  const WindowRow({
    super.key,
    required this.window,
    required this.onFocus,
    required this.onCenter,
    required this.onMaximize,
  });

  final ManagedWindow window;
  final VoidCallback onFocus;
  final VoidCallback onCenter;
  final VoidCallback onMaximize;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      child: Row(
        children: [
          _AppIcon(window: window),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        window.displayTitle,
                        style: Theme.of(context).textTheme.bodyMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (window.isFocused) ...[
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
                          'em foco',
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
                  '${window.appName} · ${window.sizeLabel}',
                  style: TextStyle(fontSize: 11.5, color: colors.text3),
                ),
              ],
            ),
          ),
          _ActionButton(
            icon: 'flip_to_front',
            tooltip: 'Trazer para frente',
            onPressed: onFocus,
          ),
          _ActionButton(
            icon: 'center_focus_strong',
            tooltip: 'Centralizar',
            onPressed: onCenter,
          ),
          _ActionButton(
            icon: 'fullscreen',
            tooltip: 'Maximizar',
            onPressed: onMaximize,
          ),
        ],
      ),
    );
  }
}

class _AppIcon extends StatelessWidget {
  const _AppIcon({required this.window});

  final ManagedWindow window;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final icon = window.icon;

    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: colors.hover,
        borderRadius: BorderRadius.circular(7),
      ),
      alignment: Alignment.center,
      clipBehavior: Clip.antiAlias,
      child: icon != null
          ? Image.memory(icon, width: 24, height: 24, gaplessPlayback: true)
          : MsIcon('web_asset', size: 15, color: colors.text3),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final String icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Tooltip(
      message: tooltip,
      waitDuration: const Duration(milliseconds: 400),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(7),
        hoverColor: colors.hover,
        child: SizedBox(
          width: 28,
          height: 28,
          child: Center(child: MsIcon(icon, size: 15, color: colors.text2)),
        ),
      ),
    );
  }
}
