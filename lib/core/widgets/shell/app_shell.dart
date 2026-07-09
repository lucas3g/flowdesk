import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../features/backup/presentation/pages/backup_page.dart';
import '../../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../../features/favorites/presentation/pages/favorites_page.dart';
import '../../../features/history/presentation/pages/history_page.dart';
import '../../../features/layout_editor/presentation/pages/layout_editor_page.dart';
import '../../../features/layouts/presentation/pages/layouts_page.dart';
import '../../../features/monitors/presentation/pages/monitors_page.dart';
import '../../../features/permissions/presentation/widgets/permissions_banner.dart';
import '../../../features/rules/presentation/pages/rules_page.dart';
import '../../../features/settings/presentation/pages/settings_page.dart';
import '../../../features/shortcuts/presentation/pages/shortcuts_page.dart';
import '../../../features/windows/presentation/cubits/undo_redo_cubit.dart';
import '../../../features/windows/presentation/pages/windows_page.dart';
import '../../../features/workspaces/presentation/pages/workspaces_page.dart';
import '../../di/injection.dart';
import '../../routing/app_screen.dart';
import '../../routing/navigation_cubit.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../../features/settings/presentation/cubits/settings_cubit.dart';
import '../command_palette.dart';
import '../onboarding_dialog.dart';
import 'sidebar.dart';
import 'title_bar.dart';

/// Estrutura principal do app: titlebar no topo, sidebar à esquerda e
/// conteúdo da tela ativa com transição de fade/slide.
class AppShell extends StatelessWidget {
  AppShell({super.key});

  final NavigationCubit _navigationCubit = getIt<NavigationCubit>();

  Widget _pageFor(AppScreen screen) {
    return switch (screen) {
      AppScreen.dashboard => const DashboardPage(),
      AppScreen.layouts => const LayoutsPage(),
      AppScreen.layoutEditor => LayoutEditorPage(),
      AppScreen.workspaces => const WorkspacesPage(),
      AppScreen.monitors => MonitorsPage(),
      AppScreen.windows => const WindowsPage(),
      AppScreen.rules => const RulesPage(),
      AppScreen.shortcuts => const ShortcutsPage(),
      AppScreen.history => const HistoryPage(),
      AppScreen.favorites => const FavoritesPage(),
      AppScreen.backup => BackupPage(),
      AppScreen.settings => SettingsPage(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return BlocBuilder<NavigationCubit, AppScreen>(
      bloc: _navigationCubit,
      builder: (context, screen) => _buildShell(colors, screen),
    );
  }

  Widget _buildShell(FlowDeskColors colors, AppScreen screen) {
    return Scaffold(
      backgroundColor: colors.window,
      body: _OnboardingGate(
        child: _PaletteShortcut(
          child: Column(
        children: [
          TitleBar(),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Sidebar(),
                Expanded(
                  child: ColoredBox(
                    color: colors.content,
                    child: Column(
                      children: [
                        PermissionsBanner(),
                        Expanded(
                          child: _ScreenSwitcher(
                            screen: screen,
                            child: _pageFor(screen),
                          ),
                        ),
                      ],
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
  }
}

/// Exibe o onboarding automaticamente na primeira execução.
class _OnboardingGate extends StatefulWidget {
  const _OnboardingGate({required this.child});

  final Widget child;

  @override
  State<_OnboardingGate> createState() => _OnboardingGateState();
}

class _OnboardingGateState extends State<_OnboardingGate> {
  bool _checked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_checked || !mounted) return;
      _checked = true;
      final settings = getIt<SettingsCubit>().state.settings;
      if (!settings.onboardingDone) showOnboarding(context);
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// Atalhos do shell: ⌘K (paleta), ⌘Z (desfazer) e ⇧⌘Z (refazer).
class _PaletteShortcut extends StatelessWidget {
  const _PaletteShortcut({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyK, meta: true): () =>
            showCommandPalette(context),
        const SingleActivator(LogicalKeyboardKey.keyZ, meta: true): () =>
            getIt<UndoRedoCubit>().undo(),
        const SingleActivator(
          LogicalKeyboardKey.keyZ,
          meta: true,
          shift: true,
        ): () => getIt<UndoRedoCubit>().redo(),
      },
      child: Focus(autofocus: true, child: child),
    );
  }
}

/// Transição de fade/slide entre telas, como no design de referência.
class _ScreenSwitcher extends StatelessWidget {
  const _ScreenSwitcher({required this.screen, required this.child});

  final AppScreen screen;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: AppDimens.transitionScreen,
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.012),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: KeyedSubtree(key: ValueKey(screen), child: child),
    );
  }
}
