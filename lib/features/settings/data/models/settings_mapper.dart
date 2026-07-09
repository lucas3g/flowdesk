import 'package:drift/drift.dart';

import '../../../../core/services/database/app_database.dart';
import '../../domain/entities/app_settings.dart';

/// Conversões entre a linha do banco e a entidade de domínio.
extension SettingsRowMapper on SettingsRow {
  AppSettings toEntity() {
    return AppSettings(
      themePreference: ThemePreference.values.firstWhere(
        (p) => p.name == themePreference,
        orElse: () => ThemePreference.system,
      ),
      language: language,
      launchAtLogin: launchAtLogin,
      showMenuBarIcon: showMenuBarIcon,
      showInDock: showInDock,
      magneticSnap: magneticSnap,
      animateTransitions: animateTransitions,
      animationDurationMs: animationDurationMs,
      windowGap: windowGap,
      screenMargin: screenMargin,
      barTransparency: barTransparency,
      onboardingDone: onboardingDone,
      userName: userName,
    );
  }
}

extension AppSettingsMapper on AppSettings {
  SettingsTableCompanion toCompanion() {
    return SettingsTableCompanion(
      id: const Value(0),
      themePreference: Value(themePreference.name),
      language: Value(language),
      launchAtLogin: Value(launchAtLogin),
      showMenuBarIcon: Value(showMenuBarIcon),
      showInDock: Value(showInDock),
      magneticSnap: Value(magneticSnap),
      animateTransitions: Value(animateTransitions),
      animationDurationMs: Value(animationDurationMs),
      windowGap: Value(windowGap),
      screenMargin: Value(screenMargin),
      barTransparency: Value(barTransparency),
      onboardingDone: Value(onboardingDone),
      userName: Value(userName),
    );
  }
}
