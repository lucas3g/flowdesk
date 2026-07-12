import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:window_manager/window_manager.dart';

import '../../../features/settings/presentation/cubits/settings_cubit.dart';
import '../../../features/windows/presentation/cubits/undo_redo_cubit.dart';
import '../../constants/app_constants.dart';
import '../../di/injection.dart';
import '../../routing/app_screen.dart';
import '../../routing/navigation_cubit.dart';
import '../../theme/app_colors.dart';
import '../../tour/tour_targets.dart';
import '../../theme/app_dimens.dart';
import '../command_palette.dart';
import '../ms_icon.dart';
import '../onboarding_dialog.dart';

/// Barra de título customizada (52px): logo, breadcrumb, busca ⌘K e ações.
///
/// Os botões nativos do macOS (semáforo) permanecem sobrepostos à esquerda,
/// por isso o conteúdo começa após um recuo fixo.
class TitleBar extends StatelessWidget {
  TitleBar({super.key});

  final NavigationCubit _navigationCubit = getIt<NavigationCubit>();
  final SettingsCubit _settingsCubit = getIt<SettingsCubit>();

  /// Espaço reservado para os botões nativos de fechar/minimizar/maximizar.
  static const double _trafficLightsInset = 78;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return BlocBuilder<NavigationCubit, AppScreen>(
      bloc: _navigationCubit,
      builder: (context, screen) => _buildBar(context, colors, screen),
    );
  }

  Widget _buildBar(
    BuildContext context,
    FlowDeskColors colors,
    AppScreen screen,
  ) {
    return DragToMoveArea(
      child: Container(
        height: AppDimens.titlebarHeight,
        decoration: BoxDecoration(
          color: colors.titlebar,
          border: Border(bottom: BorderSide(color: colors.separator)),
        ),
        padding: const EdgeInsets.only(left: _trafficLightsInset, right: 14),
        child: Row(
          children: [
            Container(width: 1, height: 22, color: colors.separator),
            const SizedBox(width: 14),
            _AppLogo(colors: colors),
            const SizedBox(width: 10),
            Text(
              AppConstants.appName,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: colors.text,
              ),
            ),
            if (screen.breadcrumbTitle != null) ...[
              const SizedBox(width: 6),
              MsIcon('chevron_right', size: 16, color: colors.text3),
              const SizedBox(width: 6),
              Text(
                screen.breadcrumbTitle!,
                style: TextStyle(fontSize: 13.5, color: colors.text2),
              ),
            ],
            const Spacer(),
            _UndoRedoButtons(),
            const SizedBox(width: 8),
            _SearchTrigger(key: TourTargets.commandPalette),
            const SizedBox(width: 10),
            _TitleBarIconButton(
              icon: Theme.of(context).brightness == Brightness.dark
                  ? 'light_mode'
                  : 'dark_mode',
              tooltip: 'Alternar tema',
              onPressed: () =>
                  _settingsCubit.toggleTheme(Theme.of(context).brightness),
            ),
            const SizedBox(width: 4),
            _TitleBarIconButton(
              icon: 'auto_awesome',
              tooltip: 'Assistente de primeiro uso',
              onPressed: () => showOnboarding(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppLogo extends StatelessWidget {
  const _AppLogo({required this.colors});

  final FlowDeskColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.blue, colors.purple],
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      alignment: Alignment.center,
      child: const MsIcon('grid_view', size: 14, color: Colors.white),
    );
  }
}

/// Desfazer/refazer movimentações de janelas (⌘Z / ⇧⌘Z).
class _UndoRedoButtons extends StatelessWidget {
  _UndoRedoButtons();

  final UndoRedoCubit _cubit = getIt<UndoRedoCubit>();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return BlocBuilder<UndoRedoCubit, UndoRedoState>(
      bloc: _cubit,
      builder: (context, state) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _TitleBarIconButton(
              icon: 'undo',
              tooltip: 'Desfazer movimentação (⌘Z)',
              onPressed: state.canUndo ? _cubit.undo : () {},
              color: state.canUndo ? colors.text2 : colors.text3,
            ),
            _TitleBarIconButton(
              icon: 'redo',
              tooltip: 'Refazer movimentação (⇧⌘Z)',
              onPressed: state.canRedo ? _cubit.redo : () {},
              color: state.canRedo ? colors.text2 : colors.text3,
            ),
          ],
        );
      },
    );
  }
}

/// Campo que abre a paleta de comandos (⌘K).
class _SearchTrigger extends StatelessWidget {
  const _SearchTrigger({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return InkWell(
      onTap: () => showCommandPalette(context),
      borderRadius: BorderRadius.circular(AppDimens.radiusIconButton),
      child: _buildPill(colors),
    );
  }

  Widget _buildPill(FlowDeskColors colors) {
    return Container(
      constraints: const BoxConstraints(minWidth: 230),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colors.hover,
        borderRadius: BorderRadius.circular(AppDimens.radiusIconButton),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          MsIcon('search', size: 15, color: colors.text3),
          const SizedBox(width: 8),
          Text(
            'Buscar ou executar…',
            style: TextStyle(fontSize: 12.5, color: colors.text3),
          ),
          const SizedBox(width: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
              border: Border.all(color: colors.cardBorder),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              '⌘K',
              style: TextStyle(fontSize: 10.5, color: colors.text3),
            ),
          ),
        ],
      ),
    );
  }
}

class _TitleBarIconButton extends StatelessWidget {
  const _TitleBarIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.color,
  });

  final String icon;
  final String tooltip;
  final VoidCallback onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Tooltip(
      message: tooltip,
      waitDuration: const Duration(milliseconds: 500),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppDimens.radiusIconButton),
        hoverColor: colors.hover,
        child: SizedBox(
          width: 30,
          height: 30,
          child: Center(
            child: MsIcon(icon, size: 17, color: color ?? colors.text2),
          ),
        ),
      ),
    );
  }
}
