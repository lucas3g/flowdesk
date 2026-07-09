import 'package:drift/native.dart';
import 'package:flowdesk/core/services/database/app_database.dart';
import 'package:flowdesk/core/usecases/usecase.dart';
import 'package:flowdesk/features/backup/domain/usecases/export_backup.dart';
import 'package:flowdesk/features/backup/domain/usecases/import_backup.dart';
import 'package:flowdesk/features/layouts/data/datasources/layouts_local_datasource.dart';
import 'package:flowdesk/features/layouts/data/datasources/preset_layouts.dart';
import 'package:flowdesk/features/layouts/data/repositories/layouts_repository_impl.dart';
import 'package:flowdesk/features/layouts/domain/entities/layout.dart';
import 'package:flowdesk/features/rules/data/datasources/rules_local_datasource.dart';
import 'package:flowdesk/features/rules/data/repositories/rules_repository_impl.dart';
import 'package:flowdesk/features/rules/domain/entities/rule.dart';
import 'package:flowdesk/features/settings/data/datasources/settings_local_datasource.dart';
import 'package:flowdesk/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:flowdesk/features/settings/domain/entities/app_settings.dart';
import 'package:flowdesk/features/workspaces/data/datasources/workspaces_local_datasource.dart';
import 'package:flowdesk/features/workspaces/data/repositories/workspaces_repository_impl.dart';
import 'package:flowdesk/features/workspaces/domain/entities/workspace.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';

/// Monta os quatro repositórios reais sobre um banco em memória.
({
  AppDatabase db,
  LayoutsRepositoryImpl layouts,
  WorkspacesRepositoryImpl workspaces,
  RulesRepositoryImpl rules,
  SettingsRepositoryImpl settings,
})
_buildStack() {
  final db = AppDatabase.withExecutor(NativeDatabase.memory());
  return (
    db: db,
    layouts: LayoutsRepositoryImpl(LayoutsLocalDatasourceImpl(db)),
    workspaces: WorkspacesRepositoryImpl(WorkspacesLocalDatasourceImpl(db)),
    rules: RulesRepositoryImpl(
      RulesLocalDatasourceImpl(db),
      FakeEventChannel(const Stream.empty()),
    ),
    settings: SettingsRepositoryImpl(SettingsLocalDatasourceImpl(db)),
  );
}

void main() {
  test('roundtrip: exporta de uma instalação e importa em outra', () async {
    // Instalação de origem com dados do usuário.
    final source = _buildStack();
    await source.layouts.getLayouts(); // semeia presets

    final customLayout = (await source.layouts.saveLayout(
      const Layout(
        name: 'Meu Layout',
        category: LayoutCategory.dev,
        isFavorite: true,
        shortcut: '⌥⌘1',
        regions: [
          LayoutRegion(name: 'A', x: 0, y: 0, width: 60, height: 100),
          LayoutRegion(
            name: 'B',
            x: 60,
            y: 0,
            width: 40,
            height: 100,
            sortOrder: 1,
          ),
        ],
      ),
    )).getOrElse((f) => fail(f.message));

    await source.workspaces.saveWorkspace(
      Workspace(
        name: 'Meu Workspace',
        emoji: '🚀',
        layoutId: customLayout.id,
        apps: const [WorkspaceApp(bundleId: 'com.x', appName: 'X')],
      ),
    );
    await source.rules.saveRule(
      const Rule(
        bundleId: 'com.x',
        appName: 'X',
        actionType: RuleActionType.maximize,
      ),
    );
    await source.settings.saveSettings(
      const AppSettings(themePreference: ThemePreference.dark, windowGap: 16),
    );

    final json = (await ExportBackup(
      source.layouts,
      source.workspaces,
      source.rules,
      source.settings,
    )(const NoParams())).getOrElse((f) => fail(f.message));

    // Presets não entram no export.
    expect(json.contains('Meu Layout'), isTrue);
    expect(json.contains('"Golden Ratio"'), isFalse);

    // Instalação de destino limpa.
    final target = _buildStack();
    final summary = (await ImportBackup(
      target.layouts,
      target.workspaces,
      target.rules,
      target.settings,
    )(json)).getOrElse((f) => fail(f.message));

    expect(summary.layouts, 1);
    expect(summary.workspaces, greaterThanOrEqualTo(1));
    expect(summary.rules, 1);
    expect(summary.settingsApplied, isTrue);

    final imported = (await target.layouts.getLayouts()).getOrElse(
      (f) => fail(f.message),
    );
    final myLayout = imported.firstWhere((l) => l.name == 'Meu Layout');
    expect(myLayout.regions.length, 2);
    expect(myLayout.isFavorite, isTrue);
    expect(myLayout.shortcut, '⌥⌘1');

    // Vínculo workspace→layout resolvido por nome na importação.
    final workspaces = (await target.workspaces.getWorkspaces()).getOrElse(
      (f) => fail(f.message),
    );
    final myWorkspace = workspaces.firstWhere((w) => w.name == 'Meu Workspace');
    expect(myWorkspace.layoutId, myLayout.id);

    final settings = (await target.settings.getSettings()).getOrElse(
      (f) => fail(f.message),
    );
    expect(settings.themePreference, ThemePreference.dark);
    expect(settings.windowGap, 16);

    await source.db.close();
    await target.db.close();
  });

  test('import rejeita JSON que não é backup do FlowDesk', () async {
    final target = _buildStack();

    final result = await ImportBackup(
      target.layouts,
      target.workspaces,
      target.rules,
      target.settings,
    )('{"foo": 1}');

    expect(result.isLeft(), isTrue);
    await target.db.close();
  });

  test('presets são semeados na importação em instalação nova', () async {
    // Garante que importar em banco vazio não perde os presets.
    final target = _buildStack();
    await ImportBackup(
      target.layouts,
      target.workspaces,
      target.rules,
      target.settings,
    )('{"app":"FlowDesk","version":1,"layouts":[]}');

    final layouts = (await target.layouts.getLayouts()).getOrElse(
      (f) => fail(f.message),
    );
    expect(layouts.length, presetLayouts.length);
    await target.db.close();
  });
}
