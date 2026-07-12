import 'dart:convert';

import '../../layouts/domain/entities/layout.dart';
import '../../rules/domain/entities/rule.dart';
import '../../settings/domain/entities/app_settings.dart';
import '../../workspaces/domain/entities/workspace.dart';

/// Conteúdo de um backup do FlowDesk.
class BackupData {
  const BackupData({
    this.layouts = const [],
    this.workspaces = const [],
    this.rules = const [],
    this.settings,
  });

  final List<Layout> layouts;
  final List<Workspace> workspaces;
  final List<Rule> rules;
  final AppSettings? settings;
}

/// Serialização do backup em JSON (versão 1).
///
/// Workspaces referenciam layouts por nome — ids locais não são portáveis
/// entre máquinas.
abstract final class BackupCodec {
  static const int version = 1;

  static String encode(
    BackupData data, {
    required Map<int, String> layoutNames,
  }) {
    return const JsonEncoder.withIndent('  ').convert({
      'app': 'FlowDesk',
      'version': version,
      'layouts': [
        for (final layout in data.layouts)
          {
            'name': layout.name,
            'category': layout.category.name,
            'isFavorite': layout.isFavorite,
            'shortcut': layout.shortcut,
            'regions': [
              for (final region in layout.regions)
                {
                  'name': region.name,
                  'x': region.x,
                  'y': region.y,
                  'width': region.width,
                  'height': region.height,
                  'colorHex': region.colorHex,
                  'sortOrder': region.sortOrder,
                  'appBundleId': region.appBundleId,
                  'appName': region.appName,
                  'appWindowTitle': region.appWindowTitle,
                },
            ],
          },
      ],
      'workspaces': [
        for (final workspace in data.workspaces)
          {
            'name': workspace.name,
            'emoji': workspace.emoji,
            'gradientStartHex': workspace.gradientStartHex,
            'gradientEndHex': workspace.gradientEndHex,
            'shortcut': workspace.shortcut,
            'layoutName': workspace.layoutId != null
                ? layoutNames[workspace.layoutId]
                : null,
            'apps': [
              for (final app in workspace.apps)
                {'bundleId': app.bundleId, 'appName': app.appName},
            ],
          },
      ],
      'rules': [
        for (final rule in data.rules)
          {
            'bundleId': rule.bundleId,
            'appName': rule.appName,
            'actionType': rule.actionType.name,
            'targetValue': rule.targetValue,
            'isActive': rule.isActive,
          },
      ],
      if (data.settings != null)
        'settings': {
          'themePreference': data.settings!.themePreference.name,
          'language': data.settings!.language,
          'launchAtLogin': data.settings!.launchAtLogin,
          'showMenuBarIcon': data.settings!.showMenuBarIcon,
          'showInDock': data.settings!.showInDock,
          'magneticSnap': data.settings!.magneticSnap,
          'animateTransitions': data.settings!.animateTransitions,
          'animationDurationMs': data.settings!.animationDurationMs,
          'windowGap': data.settings!.windowGap,
          'screenMargin': data.settings!.screenMargin,
          'barTransparency': data.settings!.barTransparency,
          'snapToLayoutRegions': data.settings!.snapToLayoutRegions,
          // Exclusões por instância ficam de fora: o id da janela só vale
          // na sessão em que foi capturado.
          'snapExcludedApps': [
            for (final app in data.settings!.snapExcludedApps)
              if (app.windowId == null)
                {'bundleId': app.bundleId, 'appName': app.appName},
          ],
        },
    });
  }

  /// Decodifica; lança [FormatException] para conteúdo inválido.
  /// Retorna também o nome do layout de cada workspace (resolvido para
  /// id no momento da importação).
  static ({BackupData data, Map<String, String?> workspaceLayoutNames}) decode(
    String json,
  ) {
    final root = jsonDecode(json);
    if (root is! Map<String, dynamic> || root['app'] != 'FlowDesk') {
      throw const FormatException('Arquivo não é um backup do FlowDesk.');
    }

    final layouts = <Layout>[
      for (final raw in root['layouts'] as List? ?? const [])
        if (raw is Map)
          Layout(
            name: '${raw['name'] ?? 'Layout'}',
            category: LayoutCategory.fromName('${raw['category'] ?? ''}'),
            isFavorite: raw['isFavorite'] == true,
            shortcut: raw['shortcut'] as String?,
            regions: [
              for (final region in raw['regions'] as List? ?? const [])
                if (region is Map)
                  LayoutRegion(
                    name: '${region['name'] ?? 'Região'}',
                    x: (region['x'] as num?)?.toDouble() ?? 0,
                    y: (region['y'] as num?)?.toDouble() ?? 0,
                    width: (region['width'] as num?)?.toDouble() ?? 10,
                    height: (region['height'] as num?)?.toDouble() ?? 10,
                    colorHex: '${region['colorHex'] ?? '#0A84FF'}',
                    sortOrder: (region['sortOrder'] as num?)?.toInt() ?? 0,
                    appBundleId: region['appBundleId'] as String?,
                    appName: region['appName'] as String?,
                    appWindowTitle: region['appWindowTitle'] as String?,
                  ),
            ],
          ),
    ];

    final workspaceLayoutNames = <String, String?>{};
    final workspaces = <Workspace>[
      for (final raw in root['workspaces'] as List? ?? const [])
        if (raw is Map)
          () {
            final name = '${raw['name'] ?? 'Workspace'}';
            workspaceLayoutNames[name] = raw['layoutName'] as String?;
            return Workspace(
              name: name,
              emoji: '${raw['emoji'] ?? '💻'}',
              gradientStartHex: '${raw['gradientStartHex'] ?? '#0A84FF'}',
              gradientEndHex: '${raw['gradientEndHex'] ?? '#40C8E0'}',
              shortcut: raw['shortcut'] as String?,
              apps: [
                for (final app in raw['apps'] as List? ?? const [])
                  if (app is Map)
                    WorkspaceApp(
                      bundleId: '${app['bundleId'] ?? ''}',
                      appName: '${app['appName'] ?? ''}',
                    ),
              ],
            );
          }(),
    ];

    final rules = <Rule>[
      for (final raw in root['rules'] as List? ?? const [])
        if (raw is Map)
          Rule(
            bundleId: '${raw['bundleId'] ?? ''}',
            appName: '${raw['appName'] ?? ''}',
            actionType: RuleActionType.fromName('${raw['actionType'] ?? ''}'),
            targetValue: '${raw['targetValue'] ?? ''}',
            isActive: raw['isActive'] == true,
          ),
    ];

    AppSettings? settings;
    final rawSettings = root['settings'];
    if (rawSettings is Map) {
      settings = AppSettings(
        themePreference: ThemePreference.values.firstWhere(
          (p) => p.name == rawSettings['themePreference'],
          orElse: () => ThemePreference.system,
        ),
        language: '${rawSettings['language'] ?? 'pt_BR'}',
        launchAtLogin: rawSettings['launchAtLogin'] == true,
        showMenuBarIcon: rawSettings['showMenuBarIcon'] != false,
        showInDock: rawSettings['showInDock'] != false,
        magneticSnap: rawSettings['magneticSnap'] != false,
        animateTransitions: rawSettings['animateTransitions'] != false,
        animationDurationMs:
            (rawSettings['animationDurationMs'] as num?)?.toInt() ?? 200,
        windowGap: (rawSettings['windowGap'] as num?)?.toDouble() ?? 8,
        screenMargin: (rawSettings['screenMargin'] as num?)?.toDouble() ?? 8,
        barTransparency: rawSettings['barTransparency'] != false,
        snapToLayoutRegions: rawSettings['snapToLayoutRegions'] == true,
        snapExcludedApps: [
          if (rawSettings['snapExcludedApps'] is List)
            for (final entry in rawSettings['snapExcludedApps'] as List)
              if (entry is Map && entry['bundleId'] is String)
                SnapExcludedApp(
                  bundleId: entry['bundleId'] as String,
                  appName: '${entry['appName'] ?? ''}',
                ),
        ],
      );
    }

    return (
      data: BackupData(
        layouts: layouts,
        workspaces: workspaces,
        rules: rules,
        settings: settings,
      ),
      workspaceLayoutNames: workspaceLayoutNames,
    );
  }
}
