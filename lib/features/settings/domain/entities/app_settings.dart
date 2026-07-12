import 'package:equatable/equatable.dart';

/// Preferência de tema do usuário (independente do Flutter para manter
/// o domínio desacoplado da camada de apresentação).
enum ThemePreference { system, light, dark }

/// App — ou uma instância específica dele — excluído do encaixe ao
/// arrastar (nome e título são apenas para exibição).
class SnapExcludedApp extends Equatable {
  const SnapExcludedApp({
    required this.bundleId,
    required this.appName,
    this.windowId,
    this.windowTitle,
  });

  final String bundleId;
  final String appName;

  /// Id único da janela (CGWindowID no macOS, HWND no Windows) quando a
  /// exclusão vale só para uma instância; null exclui o app inteiro.
  /// O id vale enquanto a janela existir — fechá-la encerra a exclusão.
  final int? windowId;

  /// Título da janela no momento da exclusão (apenas exibição).
  final String? windowTitle;

  @override
  List<Object?> get props => [bundleId, appName, windowId, windowTitle];
}

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
    this.snapToLayoutRegions = false,
    this.snapExcludedApps = const [],
    this.preferredMonitorId,
    // Default true pelo mesmo motivo do onboarding: evita reexibir o tour
    // antes da linha persistida carregar; o valor real vem do banco.
    this.featureTourDone = true,
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

  /// Usar as regiões dos layouts aplicados como zonas de encaixe
  /// ao arrastar janelas (o layout aplicado em cada monitor fica no
  /// AppliedLayoutsCubit, não aqui).
  final bool snapToLayoutRegions;

  /// Apps que não participam do encaixe ao arrastar (regiões e bordas).
  final List<SnapExcludedApp> snapExcludedApps;

  /// Monitor padrão para aplicar layouts; null = automático (janela em foco).
  final int? preferredMonitorId;

  /// Tour guiado de primeiro uso já exibido (concluído ou pulado).
  final bool featureTourDone;

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
    bool? snapToLayoutRegions,
    List<SnapExcludedApp>? snapExcludedApps,
    int? Function()? preferredMonitorId,
    bool? featureTourDone,
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
      snapToLayoutRegions: snapToLayoutRegions ?? this.snapToLayoutRegions,
      snapExcludedApps: snapExcludedApps ?? this.snapExcludedApps,
      preferredMonitorId: preferredMonitorId != null
          ? preferredMonitorId()
          : this.preferredMonitorId,
      featureTourDone: featureTourDone ?? this.featureTourDone,
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
    snapToLayoutRegions,
    snapExcludedApps,
    preferredMonitorId,
    featureTourDone,
  ];
}
