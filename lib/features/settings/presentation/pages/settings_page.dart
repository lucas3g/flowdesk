import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/tour/feature_tour.dart';
import '../../../../core/widgets/ms_icon.dart';
import '../../../licensing/presentation/widgets/license_section.dart';
import '../../domain/entities/app_settings.dart';
import '../cubits/settings_cubit.dart';
import '../cubits/settings_state.dart';
import '../widgets/settings_group.dart';
import '../widgets/snap_excluded_apps_row.dart';

/// Tela de Configurações: grupos Geral, Comportamento e Aparência.
class SettingsPage extends StatelessWidget {
  SettingsPage({super.key});

  final SettingsCubit _cubit = getIt<SettingsCubit>();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return BlocBuilder<SettingsCubit, SettingsState>(
      bloc: _cubit,
      builder: (context, state) {
        final settings = state.settings;

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
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: colors.hover,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: MsIcon(
                          'settings',
                          size: 21,
                          color: colors.text2,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Configurações',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            'Preferências do FlowDesk',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  const LicenseSection(),
                  const SizedBox(height: 18),
                  SettingsGroup(
                    title: 'GERAL',
                    children: [
                      SettingsToggleRow(
                        icon: 'power_settings_new',
                        label: 'Iniciar com o macOS',
                        subtitle: 'Abrir o FlowDesk automaticamente ao ligar',
                        value: settings.launchAtLogin,
                        onChanged: _cubit.setLaunchAtLogin,
                      ),
                      SettingsToggleRow(
                        icon: 'toolbar',
                        label: 'Ícone na barra de menu',
                        value: settings.showMenuBarIcon,
                        onChanged: _cubit.setShowMenuBarIcon,
                      ),
                      SettingsToggleRow(
                        icon: 'dock_to_bottom',
                        label: 'Mostrar no Dock',
                        subtitle:
                            'Quando desativado, o app vive apenas na barra de menu',
                        value: settings.showInDock,
                        onChanged: _cubit.setShowInDock,
                      ),
                      SettingsValueRow<String>(
                        icon: 'language',
                        label: 'Idioma',
                        value: settings.language,
                        options: const {
                          'pt_BR': 'Português (BR)',
                          'en_US': 'English (US)',
                        },
                        onChanged: _cubit.setLanguage,
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  SettingsGroup(
                    title: 'COMPORTAMENTO',
                    children: [
                      SettingsToggleRow(
                        icon: 'magnet',
                        label: 'Encaixe magnético',
                        subtitle:
                            'Sugerir regiões ao aproximar janelas das bordas',
                        value: settings.magneticSnap,
                        onChanged: _cubit.setMagneticSnap,
                      ),
                      SettingsToggleRow(
                        icon: 'grid_view',
                        label: 'Encaixar nas regiões do layout',
                        subtitle:
                            'Ao arrastar uma janela, mostra as regiões do '
                            'último layout aplicado e encaixa ao soltar',
                        value: settings.snapToLayoutRegions,
                        onChanged: _cubit.setSnapToLayoutRegions,
                      ),
                      SnapExcludedAppsRow(
                        apps: settings.snapExcludedApps,
                        onChanged: _cubit.setSnapExcludedApps,
                      ),
                      SettingsToggleRow(
                        icon: 'animation',
                        label: 'Animar transições',
                        value: settings.animateTransitions,
                        onChanged: _cubit.setAnimateTransitions,
                      ),
                      SettingsValueRow<int>(
                        icon: 'timer',
                        label: 'Tempo de animação',
                        value: settings.animationDurationMs,
                        options: const {
                          150: '150 ms',
                          200: '200 ms',
                          250: '250 ms',
                          300: '300 ms',
                        },
                        onChanged: _cubit.setAnimationDurationMs,
                      ),
                      SettingsValueRow<double>(
                        icon: 'space_bar',
                        label: 'Espaçamento entre janelas',
                        value: settings.windowGap,
                        options: {
                          0.0: '0 px',
                          4.0: '4 px',
                          8.0: '8 px',
                          12.0: '12 px',
                          16.0: '16 px',
                        },
                        onChanged: _cubit.setWindowGap,
                      ),
                      SettingsValueRow<double>(
                        icon: 'fit_screen',
                        label: 'Margem da tela',
                        value: settings.screenMargin,
                        options: {
                          0.0: '0 px',
                          4.0: '4 px',
                          8.0: '8 px',
                          12.0: '12 px',
                          16.0: '16 px',
                          24.0: '24 px',
                        },
                        onChanged: _cubit.setScreenMargin,
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  SettingsGroup(
                    title: 'APARÊNCIA',
                    children: [
                      SettingsValueRow<ThemePreference>(
                        icon: 'contrast',
                        label: 'Tema',
                        value: settings.themePreference,
                        options: const {
                          ThemePreference.system: 'Automático',
                          ThemePreference.light: 'Claro',
                          ThemePreference.dark: 'Escuro',
                        },
                        onChanged: _cubit.setThemePreference,
                      ),
                      SettingsToggleRow(
                        icon: 'blur_on',
                        label: 'Transparência da barra',
                        value: settings.barTransparency,
                        onChanged: _cubit.setBarTransparency,
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  SettingsGroup(
                    title: 'AJUDA',
                    children: [
                      SettingsActionRow(
                        icon: 'tips_and_updates',
                        label: 'Tour guiado',
                        subtitle:
                            'Reveja onde fica cada função essencial do app',
                        buttonLabel: 'Rever tour',
                        onPressed: () => showFeatureTour(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
