import 'package:drift/drift.dart';

/// Layouts salvos (presets do sistema e criados pelo usuário).
@DataClassName('LayoutRow')
class Layouts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 80)();
  TextColumn get category => text().withDefault(const Constant('geral'))();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  BoolColumn get isPreset => boolean().withDefault(const Constant(false))();
  TextColumn get shortcut => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

/// Regiões de um layout, em percentuais (0–100) da área útil do monitor.
@DataClassName('LayoutRegionRow')
class LayoutRegions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get layoutId =>
      integer().references(Layouts, #id, onDelete: KeyAction.cascade)();
  TextColumn get name => text().withLength(min: 1, max: 60)();
  RealColumn get x => real()();
  RealColumn get y => real()();
  RealColumn get width => real()();
  RealColumn get height => real()();
  TextColumn get colorHex => text().withDefault(const Constant('#0A84FF'))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  /// App associado à região — sempre recebe a janela desse app ao aplicar
  /// o layout (adicionados no schema v3).
  TextColumn get appBundleId => text().nullable()();
  TextColumn get appName => text().nullable()();

  /// Título da janela escolhida quando o app tem várias instâncias
  /// (adicionado no schema v5).
  TextColumn get appWindowTitle => text().nullable()();
}

/// Workspaces (conjuntos de apps + layout associado).
@DataClassName('WorkspaceRow')
class Workspaces extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 80)();
  TextColumn get emoji => text().withDefault(const Constant('💻'))();
  TextColumn get gradientStartHex =>
      text().withDefault(const Constant('#0A84FF'))();
  TextColumn get gradientEndHex =>
      text().withDefault(const Constant('#40C8E0'))();
  TextColumn get shortcut => text().nullable()();
  IntColumn get layoutId =>
      integer().nullable().references(Layouts, #id, onDelete: KeyAction.setNull)();
  BoolColumn get isActive => boolean().withDefault(const Constant(false))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}

/// Apps que compõem um workspace e sua região/monitor de destino.
@DataClassName('WorkspaceAppRow')
class WorkspaceApps extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get workspaceId =>
      integer().references(Workspaces, #id, onDelete: KeyAction.cascade)();
  TextColumn get bundleId => text()();
  TextColumn get appName => text()();
  IntColumn get regionId => integer()
      .nullable()
      .references(LayoutRegions, #id, onDelete: KeyAction.setNull)();
  TextColumn get monitorRef => text().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}

/// Perfis por configuração de monitores (fingerprint da combinação
/// de telas conectadas → workspace/layout aplicado automaticamente).
@DataClassName('MonitorProfileRow')
class MonitorProfiles extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 80)();
  TextColumn get fingerprint => text().unique()();
  IntColumn get workspaceId => integer()
      .nullable()
      .references(Workspaces, #id, onDelete: KeyAction.setNull)();
  IntColumn get layoutId =>
      integer().nullable().references(Layouts, #id, onDelete: KeyAction.setNull)();
  BoolColumn get autoApply => boolean().withDefault(const Constant(true))();
}

/// Regras do tipo "se abrir o app X, mover para Y / aplicar Z".
@DataClassName('RuleRow')
class Rules extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get bundleId => text()();
  TextColumn get appName => text()();

  /// Tipo da ação (ex.: `moveToRegion`, `moveToMonitor`, `applyLayout`).
  TextColumn get actionType => text()();

  /// Alvo da ação (id da região, fingerprint do monitor, id do layout…).
  TextColumn get targetValue => text()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
}

/// Atalhos globais configuráveis (ação → combinação de teclas).
@DataClassName('ShortcutRow')
class Shortcuts extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Identificador da ação (ex.: `applyLayout:3`, `centerWindow`).
  TextColumn get action => text().unique()();

  /// Combinação serializada (ex.: `alt+cmd+1`).
  TextColumn get combo => text()();
}

/// Histórico de ações para a tela Histórico e undo/redo.
@DataClassName('HistoryEntryRow')
class HistoryEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get type => text()();
  TextColumn get title => text()();
  TextColumn get subtitle => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// Última posição conhecida de janelas por app (Auto Restore).
@DataClassName('WindowPositionRow')
class WindowPositions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get bundleId => text()();
  TextColumn get monitorFingerprint => text()();
  RealColumn get x => real()();
  RealColumn get y => real()();
  RealColumn get width => real()();
  RealColumn get height => real()();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

/// Preferências do app (linha única, id fixo 0).
@DataClassName('SettingsRow')
class SettingsTable extends Table {
  IntColumn get id => integer().withDefault(const Constant(0))();

  /// `system`, `light` ou `dark`.
  TextColumn get themePreference =>
      text().withDefault(const Constant('system'))();
  TextColumn get language => text().withDefault(const Constant('pt_BR'))();
  BoolColumn get launchAtLogin => boolean().withDefault(const Constant(false))();
  BoolColumn get showMenuBarIcon =>
      boolean().withDefault(const Constant(true))();
  BoolColumn get showInDock => boolean().withDefault(const Constant(true))();
  BoolColumn get magneticSnap => boolean().withDefault(const Constant(true))();
  BoolColumn get animateTransitions =>
      boolean().withDefault(const Constant(true))();
  IntColumn get animationDurationMs =>
      integer().withDefault(const Constant(200))();
  RealColumn get windowGap => real().withDefault(const Constant(8))();
  RealColumn get screenMargin => real().withDefault(const Constant(8))();
  BoolColumn get barTransparency =>
      boolean().withDefault(const Constant(true))();

  /// Onboarding de primeiro uso já concluído (adicionada no schema v2).
  BoolColumn get onboardingDone =>
      boolean().withDefault(const Constant(false))();

  /// Nome do usuário, informado no onboarding (adicionada no schema v4).
  TextColumn get userName => text().withDefault(const Constant(''))();

  @override
  Set<Column> get primaryKey => {id};
}
