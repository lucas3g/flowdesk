import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables.dart';

part 'app_database.g.dart';

/// Banco local do FlowDesk (SQLite via Drift).
@DriftDatabase(
  tables: [
    Layouts,
    LayoutRegions,
    Workspaces,
    WorkspaceApps,
    MonitorProfiles,
    Rules,
    Shortcuts,
    HistoryEntries,
    WindowPositions,
    SettingsTable,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'flowdesk'));

  /// Permite injetar um executor alternativo (ex.: banco em memória em testes).
  AppDatabase.withExecutor(super.executor);

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(settingsTable, settingsTable.onboardingDone);
      }
      if (from < 3) {
        await m.addColumn(layoutRegions, layoutRegions.appBundleId);
        await m.addColumn(layoutRegions, layoutRegions.appName);
      }
      if (from < 4) {
        await m.addColumn(settingsTable, settingsTable.userName);
      }
      if (from < 5) {
        await m.addColumn(layoutRegions, layoutRegions.appWindowTitle);
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
