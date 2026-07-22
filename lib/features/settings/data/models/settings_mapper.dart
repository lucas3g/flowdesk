import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../../core/services/database/app_database.dart';
import '../../domain/entities/app_settings.dart';

/// Decodifica o JSON persistido de apps excluídos do encaixe; conteúdo
/// inválido resulta em lista vazia.
List<SnapExcludedApp> decodeSnapExcludedApps(String json) {
  try {
    final decoded = jsonDecode(json);
    if (decoded is! List) return const [];
    return [
      for (final entry in decoded)
        if (entry is Map && entry['bundleId'] is String)
          SnapExcludedApp(
            bundleId: entry['bundleId'] as String,
            appName: '${entry['appName'] ?? ''}',
            windowId: entry['windowId'] is num
                ? (entry['windowId'] as num).toInt()
                : null,
            windowTitle: entry['windowTitle'] is String
                ? entry['windowTitle'] as String
                : null,
          ),
    ];
  } on FormatException {
    return const [];
  }
}

String encodeSnapExcludedApps(List<SnapExcludedApp> apps) {
  return jsonEncode([
    for (final app in apps)
      {
        'bundleId': app.bundleId,
        'appName': app.appName,
        if (app.windowId != null) 'windowId': app.windowId,
        if (app.windowTitle != null) 'windowTitle': app.windowTitle,
      },
  ]);
}

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
      snapToLayoutRegions: snapToLayoutRegions,
      keyboardSnap: keyboardSnap,
      snapExcludedApps: decodeSnapExcludedApps(snapExcludedApps),
      preferredMonitorId: preferredMonitorId,
      featureTourDone: featureTourDone,
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
      snapToLayoutRegions: Value(snapToLayoutRegions),
      keyboardSnap: Value(keyboardSnap),
      snapExcludedApps: Value(encodeSnapExcludedApps(snapExcludedApps)),
      preferredMonitorId: Value(preferredMonitorId),
      featureTourDone: Value(featureTourDone),
    );
  }
}
