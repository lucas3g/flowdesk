import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables.dart';

part 'app_database.g.dart';

/// Banco local do FlowDesk (SQLite via Drift).
@DriftDatabase(
  tables: [
    Layouts,
    LayoutRegions,
    AppliedLayouts,
    Workspaces,
    WorkspaceApps,
    MonitorProfiles,
    Rules,
    Shortcuts,
    HistoryEntries,
    WindowPositions,
    SettingsTable,
    LicenseTable,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'flowdesk'));

  /// Permite injetar um executor alternativo (ex.: banco em memória em testes).
  AppDatabase.withExecutor(super.executor);

  @override
  int get schemaVersion => 13;

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
      if (from < 6) {
        await m.createTable(licenseTable);
      }
      if (from < 7) {
        await m.addColumn(settingsTable, settingsTable.snapToLayoutRegions);
        await m.addColumn(settingsTable, settingsTable.lastAppliedLayoutId);
      }
      if (from < 8) {
        await m.addColumn(settingsTable, settingsTable.lastAppliedMonitorId);
      }
      if (from < 9) {
        await m.addColumn(settingsTable, settingsTable.snapExcludedApps);
      }
      if (from < 10) {
        await m.addColumn(settingsTable, settingsTable.preferredMonitorId);
      }
      if (from < 11) {
        await m.addColumn(settingsTable, settingsTable.featureTourDone);
      }
      if (from < 12) {
        // Layout aplicado por monitor; substitui o par global
        // lastAppliedLayoutId/lastAppliedMonitorId das settings (as colunas
        // antigas permanecem, sem uso — o id volátil não é mapeável para a
        // nova chave estável).
        await m.createTable(appliedLayouts);
      }
      if (from < 13) {
        await m.addColumn(settingsTable, settingsTable.keyboardSnap);
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
