import 'package:flowdesk/core/di/injection.dart';
import 'package:flowdesk/core/routing/app_screen.dart';
import 'package:flowdesk/core/routing/navigation_cubit.dart';
import 'package:flowdesk/core/theme/app_theme.dart';
import 'package:flowdesk/core/usecases/usecase.dart';
import 'package:flowdesk/core/widgets/shell/app_shell.dart';
import 'package:flowdesk/core/widgets/shell/sidebar.dart';
import 'package:flowdesk/features/backup/domain/usecases/export_backup.dart';
import 'package:flowdesk/features/backup/domain/usecases/import_backup.dart';
import 'package:flowdesk/features/backup/presentation/cubits/backup_cubit.dart';
import 'package:flowdesk/features/layout_editor/presentation/cubits/layout_editor_cubit.dart';
import 'package:flowdesk/features/layouts/domain/usecases/apply_layout.dart';
import 'package:flowdesk/features/layouts/domain/usecases/delete_layout.dart';
import 'package:flowdesk/features/layouts/domain/usecases/get_layouts.dart';
import 'package:flowdesk/features/history/domain/usecases/history_usecases.dart';
import 'package:flowdesk/features/history/presentation/cubits/history_cubit.dart';
import 'package:flowdesk/features/layouts/domain/usecases/save_layout.dart';
import 'package:flowdesk/features/layouts/domain/usecases/toggle_favorite_layout.dart';
import 'package:flowdesk/features/layouts/presentation/cubits/layouts_cubit.dart';
import 'package:flowdesk/features/licensing/domain/entities/license.dart';
import 'package:flowdesk/features/licensing/domain/usecases/activate_license.dart';
import 'package:flowdesk/features/licensing/domain/usecases/deactivate_license.dart';
import 'package:flowdesk/features/licensing/domain/usecases/get_license.dart';
import 'package:flowdesk/features/licensing/domain/usecases/refresh_license.dart';
import 'package:flowdesk/features/licensing/presentation/cubits/license_cubit.dart';
import 'package:flowdesk/features/monitors/domain/usecases/get_monitors.dart';
import 'package:flowdesk/features/monitors/domain/usecases/monitor_profiles_usecases.dart';
import 'package:flowdesk/features/monitors/domain/usecases/watch_monitors.dart';
import 'package:flowdesk/features/monitors/presentation/cubits/monitor_profiles_cubit.dart';
import 'package:flowdesk/features/monitors/presentation/cubits/monitors_cubit.dart';
import 'package:flowdesk/features/permissions/domain/entities/permissions_status.dart';
import 'package:flowdesk/features/rules/domain/repositories/rules_repository.dart';
import 'package:flowdesk/features/rules/domain/usecases/apply_rule_to_window.dart';
import 'package:flowdesk/features/rules/domain/usecases/delete_rule.dart';
import 'package:flowdesk/features/rules/domain/usecases/get_rules.dart';
import 'package:flowdesk/features/rules/domain/usecases/save_rule.dart';
import 'package:flowdesk/features/rules/presentation/cubits/rules_cubit.dart';
import 'package:flowdesk/features/permissions/domain/usecases/get_permissions_status.dart';
import 'package:flowdesk/features/permissions/domain/usecases/open_permission_settings.dart';
import 'package:flowdesk/features/permissions/domain/usecases/request_accessibility.dart';
import 'package:flowdesk/features/permissions/presentation/cubits/permissions_cubit.dart';
import 'package:flowdesk/features/settings/domain/entities/app_settings.dart';
import 'package:flowdesk/features/settings/domain/usecases/get_settings.dart';
import 'package:flowdesk/features/settings/domain/usecases/save_settings.dart';
import 'package:flowdesk/features/settings/presentation/cubits/settings_cubit.dart';
import 'package:flowdesk/features/windows/domain/usecases/center_window.dart';
import 'package:flowdesk/features/windows/domain/usecases/focus_window.dart';
import 'package:flowdesk/features/windows/domain/usecases/get_windows.dart';
import 'package:flowdesk/features/windows/domain/usecases/maximize_window.dart';
import 'package:flowdesk/features/windows/domain/usecases/move_resize_window.dart';
import 'package:flowdesk/features/windows/presentation/cubits/undo_redo_cubit.dart';
import 'package:flowdesk/features/windows/presentation/cubits/windows_cubit.dart';
import 'package:flowdesk/features/workspaces/domain/usecases/apply_workspace.dart';
import 'package:flowdesk/features/workspaces/domain/usecases/delete_workspace.dart';
import 'package:flowdesk/features/workspaces/domain/usecases/get_workspaces.dart';
import 'package:flowdesk/features/workspaces/domain/usecases/save_workspace.dart';
import 'package:flowdesk/features/workspaces/presentation/cubits/workspaces_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fakes.dart';
import '../../helpers/test_fonts.dart';

class _MockGetSettings extends Mock implements GetSettings {}

class _MockSaveSettings extends Mock implements SaveSettings {}

class _MockGetPermissionsStatus extends Mock implements GetPermissionsStatus {}

class _MockRequestAccessibility extends Mock implements RequestAccessibility {}

class _MockOpenPermissionSettings extends Mock
    implements OpenPermissionSettings {}

class _MockGetMonitors extends Mock implements GetMonitors {}

class _MockWatchMonitors extends Mock implements WatchMonitors {}

class _MockGetWindows extends Mock implements GetWindows {}

class _MockGetLayouts extends Mock implements GetLayouts {}

class _MockToggleFavoriteLayout extends Mock implements ToggleFavoriteLayout {}

class _MockDeleteLayout extends Mock implements DeleteLayout {}

class _MockApplyLayout extends Mock implements ApplyLayout {}

class _MockSaveLayout extends Mock implements SaveLayout {}

class _MockGetWorkspaces extends Mock implements GetWorkspaces {}

class _MockSaveWorkspace extends Mock implements SaveWorkspace {}

class _MockDeleteWorkspace extends Mock implements DeleteWorkspace {}

class _MockApplyWorkspace extends Mock implements ApplyWorkspace {}

class _MockGetRules extends Mock implements GetRules {}

class _MockSaveRule extends Mock implements SaveRule {}

class _MockDeleteRule extends Mock implements DeleteRule {}

class _MockApplyRuleToWindow extends Mock implements ApplyRuleToWindow {}

class _MockRulesRepository extends Mock implements RulesRepository {}

class _MockGetMonitorProfiles extends Mock implements GetMonitorProfiles {}

class _MockSaveMonitorProfile extends Mock implements SaveMonitorProfile {}

class _MockDeleteMonitorProfile extends Mock
    implements DeleteMonitorProfile {}

class _MockFocusWindow extends Mock implements FocusWindow {}

class _MockCenterWindow extends Mock implements CenterWindow {}

class _MockMaximizeWindow extends Mock implements MaximizeWindow {}

class _MockMoveResizeWindow extends Mock implements MoveResizeWindow {}

class _MockGetHistory extends Mock implements GetHistory {}

class _MockExportBackup extends Mock implements ExportBackup {}

class _MockImportBackup extends Mock implements ImportBackup {}

class _MockClearHistory extends Mock implements ClearHistory {}

class _MockGetLicense extends Mock implements GetLicense {}

class _MockActivateLicense extends Mock implements ActivateLicense {}

class _MockRefreshLicense extends Mock implements RefreshLicense {}

class _MockDeactivateLicense extends Mock implements DeactivateLicense {}

/// Item de navegação na sidebar (telas podem repetir o mesmo texto).
Finder _sidebarItem(AppScreen screen) => find.descendant(
  of: find.byType(Sidebar),
  matching: find.text(screen.label),
);

/// Registra no getIt os cubits usados pelos widgets do shell, com
/// use cases mockados — os widgets recuperam as instâncias via `getIt<T>()`.
Future<void> _registerCubits({bool accessibilityGranted = true}) async {
  final getSettings = _MockGetSettings();
  final saveSettings = _MockSaveSettings();
  when(() => getSettings(any())).thenAnswer(
    (_) async => right(const AppSettings()),
  );
  when(() => saveSettings(any())).thenAnswer((_) async => right(unit));

  final getPermissions = _MockGetPermissionsStatus();
  when(() => getPermissions(any())).thenAnswer(
    (_) async => right(
      PermissionsStatus(
        accessibility: accessibilityGranted,
        screenRecording: accessibilityGranted,
      ),
    ),
  );

  final getMonitors = _MockGetMonitors();
  final watchMonitors = _MockWatchMonitors();
  when(() => getMonitors(any())).thenAnswer((_) async => right(const []));
  when(() => watchMonitors(any())).thenAnswer((_) => const Stream.empty());

  final getWindows = _MockGetWindows();
  when(() => getWindows(any())).thenAnswer((_) async => right(const []));

  getIt.registerLazySingleton<NavigationCubit>(NavigationCubit.new);
  getIt.registerLazySingleton<MonitorsCubit>(
    () => MonitorsCubit(getMonitors, watchMonitors),
  );
  final getLayouts = _MockGetLayouts();
  when(() => getLayouts(any())).thenAnswer((_) async => right(const []));
  getIt.registerLazySingleton<LayoutsCubit>(
    () => LayoutsCubit(
      getLayouts,
      _MockToggleFavoriteLayout(),
      _MockDeleteLayout(),
      _MockApplyLayout(),
      _MockSaveLayout(),
      getWindows,
      getIt<MonitorsCubit>(),
      getIt<SettingsCubit>(),
      MockUndoRedoCubit(),
      FakeAddHistoryEntry(),
    ),
  );
  final getRules = _MockGetRules();
  when(() => getRules(any())).thenAnswer((_) async => right(const []));
  getIt.registerLazySingleton<RulesCubit>(
    () => RulesCubit(
      getRules,
      _MockSaveRule(),
      _MockDeleteRule(),
      _MockApplyRuleToWindow(),
      _MockRulesRepository(),
      getWindows,
      getIt<MonitorsCubit>(),
      getIt<SettingsCubit>(),
      FakeAddHistoryEntry(),
    ),
  );

  final getProfiles = _MockGetMonitorProfiles();
  when(() => getProfiles(any())).thenAnswer((_) async => right(const []));
  getIt.registerLazySingleton<MonitorProfilesCubit>(
    () => MonitorProfilesCubit(
      getProfiles,
      _MockSaveMonitorProfile(),
      _MockDeleteMonitorProfile(),
      getIt<MonitorsCubit>(),
      getIt<WorkspacesCubit>(),
      getIt<LayoutsCubit>(),
    ),
  );

  getIt.registerLazySingleton<BackupCubit>(
    () => BackupCubit(
      _MockExportBackup(),
      _MockImportBackup(),
      getIt<LayoutsCubit>(),
      getIt<WorkspacesCubit>(),
      getIt<RulesCubit>(),
      getIt<SettingsCubit>(),
    ),
  );

  getIt.registerLazySingleton<LayoutEditorCubit>(
    () => LayoutEditorCubit(_MockSaveLayout(), getIt<LayoutsCubit>()),
  );
  getIt.registerLazySingleton<UndoRedoCubit>(
    () => UndoRedoCubit(getWindows, _MockMoveResizeWindow()),
  );

  final getHistory = _MockGetHistory();
  when(() => getHistory(any())).thenAnswer((_) async => right(const []));
  getIt.registerLazySingleton<HistoryCubit>(
    () => HistoryCubit(getHistory, _MockClearHistory()),
  );

  final getWorkspaces = _MockGetWorkspaces();
  when(() => getWorkspaces(any())).thenAnswer((_) async => right(const []));
  getIt.registerLazySingleton<WorkspacesCubit>(
    () => WorkspacesCubit(
      getWorkspaces,
      _MockSaveWorkspace(),
      _MockDeleteWorkspace(),
      _MockApplyWorkspace(),
      getIt<MonitorsCubit>(),
      getIt<SettingsCubit>(),
      FakeAddHistoryEntry(),
    ),
  );
  getIt.registerLazySingleton<WindowsCubit>(
    () => WindowsCubit(
      getWindows,
      getMonitors,
      _MockFocusWindow(),
      _MockCenterWindow(),
      _MockMaximizeWindow(),
      getIt<SettingsCubit>(),
      MockUndoRedoCubit(),
    ),
  );
  getIt.registerLazySingleton<SettingsCubit>(
    () => SettingsCubit(getSettings, saveSettings, FakeApplySystemIntegration()),
  );
  getIt.registerLazySingleton<PermissionsCubit>(
    () => PermissionsCubit(
      getPermissions,
      _MockRequestAccessibility(),
      _MockOpenPermissionSettings(),
    ),
  );

  final getLicense = _MockGetLicense();
  when(() => getLicense(any())).thenAnswer((_) async => right(License.free));
  getIt.registerLazySingleton<LicenseCubit>(
    () => LicenseCubit(
      getLicense,
      _MockActivateLicense(),
      _MockRefreshLicense(),
      _MockDeactivateLicense(),
    ),
  );

  await getIt<SettingsCubit>().load();
  await getIt<PermissionsCubit>().check();
}

Widget _buildApp() {
  return MaterialApp(
    theme: AppTheme.light,
    darkTheme: AppTheme.dark,
    home: AppShell(),
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(const NoParams());
    registerFallbackValue(const AppSettings());
    return loadMaterialSymbolsFont();
  });

  tearDown(() => getIt.reset());

  testWidgets('exibe todas as entradas da sidebar', (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await _registerCubits();
    await tester.pumpWidget(_buildApp());

    for (final screen in AppScreen.values) {
      expect(find.text(screen.label), findsWidgets);
    }
  });

  testWidgets('navega para a tela de Backup pela sidebar', (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await _registerCubits();
    await tester.pumpWidget(_buildApp());

    await tester.tap(_sidebarItem(AppScreen.backup));
    await tester.pumpAndSettle();

    expect(find.text('Exportar dados'), findsOneWidget);
    expect(find.text('Importar dados'), findsOneWidget);
  });

  testWidgets('Dashboard exibe stats e seções com dados reais', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await _registerCubits();
    await tester.pumpWidget(_buildApp());
    await tester.pumpAndSettle();

    expect(find.text('Bom fluxo de trabalho hoje'), findsOneWidget);
    expect(find.text('Monitores ativos'), findsOneWidget);
    expect(find.text('Janelas abertas'), findsOneWidget);
    expect(find.text('Layouts salvos'), findsOneWidget);
    expect(find.text('Ações rápidas'), findsOneWidget);
    expect(find.text('Atividade recente'), findsOneWidget);
  });

  testWidgets('exibe a tela de Histórico', (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await _registerCubits();
    await tester.pumpWidget(_buildApp());

    await tester.tap(_sidebarItem(AppScreen.history));
    await tester.pumpAndSettle();

    expect(find.text('0 atividades registradas'), findsOneWidget);
  });

  testWidgets('exibe a tela de Favoritos', (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await _registerCubits();
    await tester.pumpWidget(_buildApp());

    await tester.tap(_sidebarItem(AppScreen.favorites));
    await tester.pumpAndSettle();

    expect(find.text('0 layouts favoritos'), findsOneWidget);
  });

  testWidgets('exibe a tela de Regras', (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await _registerCubits();
    await tester.pumpWidget(_buildApp());

    await tester.tap(_sidebarItem(AppScreen.rules));
    await tester.pumpAndSettle();

    expect(find.text('Nova regra'), findsOneWidget);
    expect(
      find.text('Nenhuma regra ainda — crie a primeira.'),
      findsOneWidget,
    );
  });

  testWidgets('exibe a galeria de Layouts com filtros', (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await _registerCubits();
    await tester.pumpWidget(_buildApp());

    await tester.tap(_sidebarItem(AppScreen.layouts));
    await tester.pumpAndSettle();

    expect(find.text('0 layouts salvos · 0 favoritos'), findsOneWidget);
    expect(find.text('Todos'), findsOneWidget);
    expect(find.text('★ Favoritos'), findsOneWidget);
  });

  testWidgets('exibe a tela de Atalhos com os grupos', (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await _registerCubits();
    await tester.pumpWidget(_buildApp());

    await tester.tap(_sidebarItem(AppScreen.shortcuts));
    await tester.pumpAndSettle();

    expect(find.text('LAYOUTS'), findsOneWidget);
    expect(find.text('WORKSPACES'), findsOneWidget);
    expect(find.text('GERAL'), findsOneWidget);
    expect(find.text('Paleta de comandos'), findsOneWidget);
    expect(find.text('⌘K'), findsWidgets);
  });

  testWidgets('exibe a tela de Workspaces', (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await _registerCubits();
    await tester.pumpWidget(_buildApp());

    await tester.tap(_sidebarItem(AppScreen.workspaces));
    await tester.pumpAndSettle();

    expect(find.text('Novo workspace'), findsOneWidget);
    expect(
      find.text('Nenhum workspace ainda — crie o primeiro.'),
      findsOneWidget,
    );
  });

  testWidgets('exibe o Editor de Layout com toolbar e inspector', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await _registerCubits();
    await tester.pumpWidget(_buildApp());

    await tester.tap(_sidebarItem(AppScreen.layoutEditor));
    await tester.pumpAndSettle();

    expect(find.text('Adicionar região'), findsOneWidget);
    expect(find.text('Salvar'), findsOneWidget);
    expect(find.text('Nenhuma região selecionada'), findsOneWidget);

    await tester.tap(find.text('Adicionar região'));
    await tester.pumpAndSettle();

    expect(find.text('1 região · não salvo'), findsOneWidget);
    expect(find.text('PRESETS'), findsOneWidget);
    expect(find.text('Excluir região'), findsOneWidget);
  });

  testWidgets('exibe a tela de Janelas com busca e tabs', (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await _registerCubits();
    await tester.pumpWidget(_buildApp());

    await tester.tap(_sidebarItem(AppScreen.windows));
    await tester.pumpAndSettle();

    expect(find.text('0 janelas abertas'), findsOneWidget);
    expect(find.text('Todos (0)'), findsOneWidget);
    expect(find.text('Nenhuma janela encontrada'), findsOneWidget);
  });

  testWidgets('exibe a tela de Monitores com a visualização', (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await _registerCubits();
    await tester.pumpWidget(_buildApp());

    await tester.tap(_sidebarItem(AppScreen.monitors));
    await tester.pumpAndSettle();

    expect(find.text('Detectar novamente'), findsOneWidget);
    expect(find.text('Nenhum monitor detectado'), findsWidgets);
  });

  testWidgets('exibe o banner quando falta a permissão de Acessibilidade', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await _registerCubits(accessibilityGranted: false);
    await tester.pumpWidget(_buildApp());
    await tester.pump();

    expect(find.text('Permissão de Acessibilidade necessária'), findsOneWidget);
    expect(find.text('Abrir Ajustes'), findsOneWidget);
  });

  testWidgets('oculta o banner quando a permissão foi concedida', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await _registerCubits();
    await tester.pumpWidget(_buildApp());
    await tester.pump();

    expect(find.text('Permissão de Acessibilidade necessária'), findsNothing);
  });

  testWidgets('exibe a tela de Configurações com os grupos do design', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await _registerCubits();
    await tester.pumpWidget(_buildApp());

    await tester.tap(_sidebarItem(AppScreen.settings));
    await tester.pumpAndSettle();

    expect(find.text('GERAL'), findsOneWidget);
    expect(find.text('COMPORTAMENTO'), findsOneWidget);
    expect(find.text('APARÊNCIA'), findsOneWidget);
    expect(find.text('Iniciar com o macOS'), findsOneWidget);
    expect(find.text('Encaixe magnético'), findsOneWidget);
    expect(find.text('Tema'), findsOneWidget);
  });
}
