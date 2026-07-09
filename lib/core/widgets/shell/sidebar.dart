import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../features/settings/presentation/cubits/settings_cubit.dart';
import '../../../features/settings/presentation/cubits/settings_state.dart';
import '../../di/injection.dart';
import '../../routing/app_screen.dart';
import '../../routing/navigation_cubit.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../ms_icon.dart';

/// Sidebar de navegação (228px) com seções, badges e rodapé de perfil.
class Sidebar extends StatelessWidget {
  Sidebar({super.key});

  final NavigationCubit _navigationCubit = getIt<NavigationCubit>();

  /// Contagens exibidas como badge. Valores reais virão das features
  /// (janelas/monitores/layouts) nas próximas etapas.
  static const Map<AppScreen, int> _badges = {
    AppScreen.layouts: 12,
    AppScreen.workspaces: 5,
    AppScreen.monitors: 3,
    AppScreen.windows: 24,
  };

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return BlocBuilder<NavigationCubit, AppScreen>(
      bloc: _navigationCubit,
      builder: (context, current) => _buildSidebar(context, colors, current),
    );
  }

  Widget _buildSidebar(
    BuildContext context,
    FlowDeskColors colors,
    AppScreen current,
  ) {
    return Container(
      width: AppDimens.sidebarWidth,
      decoration: BoxDecoration(
        color: colors.sidebar,
        border: Border(right: BorderSide(color: colors.separator)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView(
              children: [
                for (final section in SidebarSection.values) ...[
                  _SectionHeader(title: section.title),
                  for (final screen in AppScreen.values)
                    if (screen.section == section)
                      _NavRow(
                        screen: screen,
                        active: screen == current,
                        badge: _badges[screen],
                        onTap: () => _navigationCubit.navigate(screen),
                      ),
                  const SizedBox(height: 10),
                ],
              ],
            ),
          ),
          _SidebarFooter(),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 6),
      child: Text(title, style: Theme.of(context).textTheme.labelSmall),
    );
  }
}

class _NavRow extends StatelessWidget {
  const _NavRow({
    required this.screen,
    required this.active,
    required this.onTap,
    this.badge,
  });

  final AppScreen screen;
  final bool active;
  final int? badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusIconButton),
        hoverColor: colors.hover,
        child: AnimatedContainer(
          duration: AppDimens.transitionFast,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: active ? colors.selection : Colors.transparent,
            borderRadius: BorderRadius.circular(AppDimens.radiusIconButton),
          ),
          child: Row(
            children: [
              MsIcon(
                screen.iconName,
                size: 19,
                filled: active,
                color: active ? colors.blue : colors.text2,
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  screen.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                    color: active ? colors.text : colors.text2,
                  ),
                ),
              ),
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: colors.hover,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$badge',
                    style: TextStyle(fontSize: 10.5, color: colors.text3),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SidebarFooter extends StatelessWidget {
  _SidebarFooter();

  final SettingsCubit _settingsCubit = getIt<SettingsCubit>();

  /// Iniciais do nome (até duas) para o avatar.
  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    if (parts.isEmpty) return '👋';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts.first.characters.first + parts.last.characters.first)
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return BlocBuilder<SettingsCubit, SettingsState>(
      bloc: _settingsCubit,
      buildWhen: (previous, current) =>
          previous.settings.userName != current.settings.userName,
      builder: (context, state) {
        final name = state.settings.userName.trim();
        final displayName = name.isEmpty ? 'Bem-vindo' : name;
        return Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 4),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [colors.green, colors.teal],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  _initials(name),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: colors.text,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'FlowDesk',
                      style: TextStyle(fontSize: 11, color: colors.text3),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
