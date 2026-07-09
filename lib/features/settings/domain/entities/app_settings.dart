import 'package:equatable/equatable.dart';

/// Preferência de tema do usuário (independente do Flutter para manter
/// o domínio desacoplado da camada de apresentação).
enum ThemePreference { system, light, dark }

/// Preferências do aplicativo.
class AppSettings extends Equatable {
  const AppSettings({
    this.themePreference = ThemePreference.system,
    this.language = 'pt_BR',
    this.launchAtLogin = false,
    this.showMenuBarIcon = true,
    this.showInDock = true,
    this.magneticSnap = true,
    this.animateTransitions = true,
    this.animationDurationMs = 200,
    this.windowGap = 8,
    this.screenMargin = 8,
    this.barTransparency = true,
    // Default true para que telas/testes sem banco não disparem o
    // onboarding; o valor real vem da linha persistida (false no 1º uso).
    this.onboardingDone = true,
    this.userName = '',
  });

  final ThemePreference themePreference;
  final String language;
  final bool launchAtLogin;
  final bool showMenuBarIcon;
  final bool showInDock;
  final bool magneticSnap;
  final bool animateTransitions;
  final int animationDurationMs;

  /// Espaçamento entre janelas ao aplicar layouts, em pixels.
  final double windowGap;

  /// Margem entre as janelas e as bordas da tela, em pixels.
  final double screenMargin;
  final bool barTransparency;
  final bool onboardingDone;

  /// Nome exibido na sidebar e na saudação do dashboard.
  final String userName;

  AppSettings copyWith({
    ThemePreference? themePreference,
    String? language,
    bool? launchAtLogin,
    bool? showMenuBarIcon,
    bool? showInDock,
    bool? magneticSnap,
    bool? animateTransitions,
    int? animationDurationMs,
    double? windowGap,
    double? screenMargin,
    bool? barTransparency,
    bool? onboardingDone,
    String? userName,
  }) {
    return AppSettings(
      themePreference: themePreference ?? this.themePreference,
      language: language ?? this.language,
      launchAtLogin: launchAtLogin ?? this.launchAtLogin,
      showMenuBarIcon: showMenuBarIcon ?? this.showMenuBarIcon,
      showInDock: showInDock ?? this.showInDock,
      magneticSnap: magneticSnap ?? this.magneticSnap,
      animateTransitions: animateTransitions ?? this.animateTransitions,
      animationDurationMs: animationDurationMs ?? this.animationDurationMs,
      windowGap: windowGap ?? this.windowGap,
      screenMargin: screenMargin ?? this.screenMargin,
      barTransparency: barTransparency ?? this.barTransparency,
      onboardingDone: onboardingDone ?? this.onboardingDone,
      userName: userName ?? this.userName,
    );
  }

  @override
  List<Object?> get props => [
    themePreference,
    language,
    launchAtLogin,
    showMenuBarIcon,
    showInDock,
    magneticSnap,
    animateTransitions,
    animationDurationMs,
    windowGap,
    screenMargin,
    barTransparency,
    onboardingDone,
    userName,
  ];
}
