// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:flowdesk/core/di/register_module.dart' as _i132;
import 'package:flowdesk/core/platform/platform_channel.dart' as _i29;
import 'package:flowdesk/core/platform/platform_event_channel.dart' as _i649;
import 'package:flowdesk/core/routing/navigation_cubit.dart' as _i351;
import 'package:flowdesk/core/services/auto_restore_service.dart' as _i752;
import 'package:flowdesk/core/services/database/app_database.dart' as _i110;
import 'package:flowdesk/core/services/region_cycle_service.dart' as _i408;
import 'package:flowdesk/core/services/snap_regions_service.dart' as _i108;
import 'package:flowdesk/core/services/status_bar_service.dart' as _i900;
import 'package:flowdesk/core/services/window_close_service.dart' as _i466;
import 'package:flowdesk/core/services/window_snap_service.dart' as _i103;
import 'package:flowdesk/features/backup/domain/usecases/export_backup.dart'
    as _i472;
import 'package:flowdesk/features/backup/domain/usecases/import_backup.dart'
    as _i744;
import 'package:flowdesk/features/backup/presentation/cubits/backup_cubit.dart'
    as _i41;
import 'package:flowdesk/features/history/data/datasources/history_local_datasource.dart'
    as _i619;
import 'package:flowdesk/features/history/data/repositories/history_repository_impl.dart'
    as _i487;
import 'package:flowdesk/features/history/domain/repositories/history_repository.dart'
    as _i111;
import 'package:flowdesk/features/history/domain/usecases/history_usecases.dart'
    as _i618;
import 'package:flowdesk/features/history/presentation/cubits/history_cubit.dart'
    as _i431;
import 'package:flowdesk/features/layout_editor/presentation/cubits/layout_editor_cubit.dart'
    as _i1058;
import 'package:flowdesk/features/layouts/data/datasources/layouts_local_datasource.dart'
    as _i482;
import 'package:flowdesk/features/layouts/data/repositories/layouts_repository_impl.dart'
    as _i822;
import 'package:flowdesk/features/layouts/domain/repositories/layouts_repository.dart'
    as _i417;
import 'package:flowdesk/features/layouts/domain/usecases/applied_layouts_usecases.dart'
    as _i731;
import 'package:flowdesk/features/layouts/domain/usecases/apply_layout.dart'
    as _i244;
import 'package:flowdesk/features/layouts/domain/usecases/delete_layout.dart'
    as _i998;
import 'package:flowdesk/features/layouts/domain/usecases/get_layouts.dart'
    as _i238;
import 'package:flowdesk/features/layouts/domain/usecases/save_layout.dart'
    as _i854;
import 'package:flowdesk/features/layouts/domain/usecases/toggle_favorite_layout.dart'
    as _i734;
import 'package:flowdesk/features/layouts/presentation/cubits/applied_layouts_cubit.dart'
    as _i569;
import 'package:flowdesk/features/layouts/presentation/cubits/layouts_cubit.dart'
    as _i539;
import 'package:flowdesk/features/licensing/data/datasources/license_local_datasource.dart'
    as _i308;
import 'package:flowdesk/features/licensing/data/datasources/license_remote_datasource.dart'
    as _i243;
import 'package:flowdesk/features/licensing/data/repositories/license_repository_impl.dart'
    as _i922;
import 'package:flowdesk/features/licensing/data/services/entitlement_verifier.dart'
    as _i432;
import 'package:flowdesk/features/licensing/domain/repositories/license_repository.dart'
    as _i1063;
import 'package:flowdesk/features/licensing/domain/usecases/activate_license.dart'
    as _i948;
import 'package:flowdesk/features/licensing/domain/usecases/deactivate_license.dart'
    as _i1039;
import 'package:flowdesk/features/licensing/domain/usecases/get_license.dart'
    as _i726;
import 'package:flowdesk/features/licensing/domain/usecases/refresh_license.dart'
    as _i372;
import 'package:flowdesk/features/licensing/presentation/cubits/license_cubit.dart'
    as _i485;
import 'package:flowdesk/features/monitors/data/datasources/monitor_profiles_local_datasource.dart'
    as _i320;
import 'package:flowdesk/features/monitors/data/datasources/monitors_platform_datasource.dart'
    as _i204;
import 'package:flowdesk/features/monitors/data/repositories/monitor_profiles_repository_impl.dart'
    as _i620;
import 'package:flowdesk/features/monitors/data/repositories/monitors_repository_impl.dart'
    as _i336;
import 'package:flowdesk/features/monitors/domain/repositories/monitor_profiles_repository.dart'
    as _i831;
import 'package:flowdesk/features/monitors/domain/repositories/monitors_repository.dart'
    as _i640;
import 'package:flowdesk/features/monitors/domain/usecases/get_monitors.dart'
    as _i33;
import 'package:flowdesk/features/monitors/domain/usecases/monitor_profiles_usecases.dart'
    as _i493;
import 'package:flowdesk/features/monitors/domain/usecases/watch_monitors.dart'
    as _i288;
import 'package:flowdesk/features/monitors/presentation/cubits/monitor_profiles_cubit.dart'
    as _i588;
import 'package:flowdesk/features/monitors/presentation/cubits/monitors_cubit.dart'
    as _i935;
import 'package:flowdesk/features/permissions/data/datasources/permissions_platform_datasource.dart'
    as _i480;
import 'package:flowdesk/features/permissions/data/repositories/permissions_repository_impl.dart'
    as _i372;
import 'package:flowdesk/features/permissions/domain/repositories/permissions_repository.dart'
    as _i329;
import 'package:flowdesk/features/permissions/domain/usecases/get_permissions_status.dart'
    as _i178;
import 'package:flowdesk/features/permissions/domain/usecases/open_permission_settings.dart'
    as _i953;
import 'package:flowdesk/features/permissions/domain/usecases/request_accessibility.dart'
    as _i1046;
import 'package:flowdesk/features/permissions/presentation/cubits/permissions_cubit.dart'
    as _i875;
import 'package:flowdesk/features/rules/data/datasources/rules_local_datasource.dart'
    as _i538;
import 'package:flowdesk/features/rules/data/repositories/rules_repository_impl.dart'
    as _i330;
import 'package:flowdesk/features/rules/domain/repositories/rules_repository.dart'
    as _i199;
import 'package:flowdesk/features/rules/domain/usecases/apply_rule_to_window.dart'
    as _i924;
import 'package:flowdesk/features/rules/domain/usecases/delete_rule.dart'
    as _i750;
import 'package:flowdesk/features/rules/domain/usecases/get_rules.dart'
    as _i670;
import 'package:flowdesk/features/rules/domain/usecases/save_rule.dart'
    as _i443;
import 'package:flowdesk/features/rules/presentation/cubits/rules_cubit.dart'
    as _i971;
import 'package:flowdesk/features/settings/data/datasources/settings_local_datasource.dart'
    as _i1071;
import 'package:flowdesk/features/settings/data/datasources/system_platform_datasource.dart'
    as _i574;
import 'package:flowdesk/features/settings/data/repositories/settings_repository_impl.dart'
    as _i84;
import 'package:flowdesk/features/settings/data/repositories/system_integration_repository_impl.dart'
    as _i788;
import 'package:flowdesk/features/settings/domain/repositories/settings_repository.dart'
    as _i335;
import 'package:flowdesk/features/settings/domain/repositories/system_integration_repository.dart'
    as _i549;
import 'package:flowdesk/features/settings/domain/usecases/apply_system_integration.dart'
    as _i563;
import 'package:flowdesk/features/settings/domain/usecases/get_settings.dart'
    as _i122;
import 'package:flowdesk/features/settings/domain/usecases/save_settings.dart'
    as _i1066;
import 'package:flowdesk/features/settings/presentation/cubits/settings_cubit.dart'
    as _i731;
import 'package:flowdesk/features/shortcuts/data/datasources/shortcuts_platform_datasource.dart'
    as _i183;
import 'package:flowdesk/features/shortcuts/data/repositories/shortcuts_repository_impl.dart'
    as _i611;
import 'package:flowdesk/features/shortcuts/domain/repositories/shortcuts_repository.dart'
    as _i831;
import 'package:flowdesk/features/shortcuts/domain/usecases/register_shortcuts.dart'
    as _i69;
import 'package:flowdesk/features/shortcuts/domain/usecases/watch_shortcut_presses.dart'
    as _i651;
import 'package:flowdesk/features/shortcuts/presentation/cubits/shortcuts_cubit.dart'
    as _i420;
import 'package:flowdesk/features/windows/data/datasources/window_positions_local_datasource.dart'
    as _i422;
import 'package:flowdesk/features/windows/data/datasources/windows_platform_datasource.dart'
    as _i698;
import 'package:flowdesk/features/windows/data/repositories/window_positions_repository_impl.dart'
    as _i1033;
import 'package:flowdesk/features/windows/data/repositories/windows_repository_impl.dart'
    as _i572;
import 'package:flowdesk/features/windows/domain/repositories/window_positions_repository.dart'
    as _i141;
import 'package:flowdesk/features/windows/domain/repositories/windows_repository.dart'
    as _i271;
import 'package:flowdesk/features/windows/domain/usecases/center_window.dart'
    as _i561;
import 'package:flowdesk/features/windows/domain/usecases/focus_window.dart'
    as _i113;
import 'package:flowdesk/features/windows/domain/usecases/get_windows.dart'
    as _i862;
import 'package:flowdesk/features/windows/domain/usecases/maximize_window.dart'
    as _i148;
import 'package:flowdesk/features/windows/domain/usecases/move_resize_window.dart'
    as _i855;
import 'package:flowdesk/features/windows/presentation/cubits/undo_redo_cubit.dart'
    as _i607;
import 'package:flowdesk/features/windows/presentation/cubits/windows_cubit.dart'
    as _i31;
import 'package:flowdesk/features/workspaces/data/datasources/workspace_platform_datasource.dart'
    as _i836;
import 'package:flowdesk/features/workspaces/data/datasources/workspaces_local_datasource.dart'
    as _i553;
import 'package:flowdesk/features/workspaces/data/repositories/apps_launcher_repository_impl.dart'
    as _i226;
import 'package:flowdesk/features/workspaces/data/repositories/workspaces_repository_impl.dart'
    as _i89;
import 'package:flowdesk/features/workspaces/domain/repositories/apps_launcher_repository.dart'
    as _i424;
import 'package:flowdesk/features/workspaces/domain/repositories/workspaces_repository.dart'
    as _i768;
import 'package:flowdesk/features/workspaces/domain/usecases/apply_workspace.dart'
    as _i45;
import 'package:flowdesk/features/workspaces/domain/usecases/delete_workspace.dart'
    as _i290;
import 'package:flowdesk/features/workspaces/domain/usecases/get_workspaces.dart'
    as _i237;
import 'package:flowdesk/features/workspaces/domain/usecases/save_workspace.dart'
    as _i9;
import 'package:flowdesk/features/workspaces/presentation/cubits/workspaces_cubit.dart'
    as _i422;
import 'package:get_it/get_it.dart' as _i174;
import 'package:http/http.dart' as _i519;
import 'package:injectable/injectable.dart' as _i526;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();
    gh.lazySingleton<_i110.AppDatabase>(() => registerModule.database);
    gh.lazySingleton<_i519.Client>(() => registerModule.httpClient);
    gh.lazySingleton<_i351.NavigationCubit>(() => _i351.NavigationCubit());
    gh.lazySingleton<_i432.EntitlementVerifier>(
      () => _i432.EntitlementVerifier(),
    );
    gh.lazySingleton<_i422.WindowPositionsLocalDatasource>(
      () => _i422.WindowPositionsLocalDatasourceImpl(gh<_i110.AppDatabase>()),
    );
    gh.lazySingleton<_i538.RulesLocalDatasource>(
      () => _i538.RulesLocalDatasourceImpl(gh<_i110.AppDatabase>()),
    );
    gh.lazySingleton<_i482.LayoutsLocalDatasource>(
      () => _i482.LayoutsLocalDatasourceImpl(gh<_i110.AppDatabase>()),
    );
    gh.lazySingleton<_i649.PlatformEventChannel>(
      () => registerModule.monitorsEventsChannel,
      instanceName: 'monitorsEventsChannel',
    );
    gh.lazySingleton<_i29.PlatformChannel>(
      () => registerModule.shortcutsChannel,
      instanceName: 'shortcutsChannel',
    );
    gh.lazySingleton<_i29.PlatformChannel>(
      () => registerModule.monitorsChannel,
      instanceName: 'monitorsChannel',
    );
    gh.lazySingleton<_i308.LicenseLocalDatasource>(
      () => _i308.LicenseLocalDatasourceImpl(gh<_i110.AppDatabase>()),
    );
    gh.lazySingleton<_i417.LayoutsRepository>(
      () => _i822.LayoutsRepositoryImpl(gh<_i482.LayoutsLocalDatasource>()),
    );
    gh.lazySingleton<_i29.PlatformChannel>(
      () => registerModule.windowsChannel,
      instanceName: 'windowsChannel',
    );
    gh.lazySingleton<_i649.PlatformEventChannel>(
      () => registerModule.appEventsChannel,
      instanceName: 'appEventsChannel',
    );
    gh.lazySingleton<_i649.PlatformEventChannel>(
      () => registerModule.shortcutsEventsChannel,
      instanceName: 'shortcutsEventsChannel',
    );
    gh.lazySingleton<_i320.MonitorProfilesLocalDatasource>(
      () => _i320.MonitorProfilesLocalDatasourceImpl(gh<_i110.AppDatabase>()),
    );
    gh.lazySingleton<_i29.PlatformChannel>(
      () => registerModule.workspaceChannel,
      instanceName: 'workspaceChannel',
    );
    gh.lazySingleton<_i649.PlatformEventChannel>(
      () => registerModule.workspaceEventsChannel,
      instanceName: 'workspaceEventsChannel',
    );
    gh.lazySingleton<_i204.MonitorsPlatformDatasource>(
      () => _i204.MonitorsPlatformDatasourceImpl(
        gh<_i29.PlatformChannel>(instanceName: 'monitorsChannel'),
        gh<_i649.PlatformEventChannel>(instanceName: 'monitorsEventsChannel'),
      ),
    );
    gh.lazySingleton<_i29.PlatformChannel>(
      () => registerModule.appChannel,
      instanceName: 'appChannel',
    );
    gh.lazySingleton<_i619.HistoryLocalDatasource>(
      () => _i619.HistoryLocalDatasourceImpl(gh<_i110.AppDatabase>()),
    );
    gh.factory<_i731.GetAppliedLayouts>(
      () => _i731.GetAppliedLayouts(gh<_i417.LayoutsRepository>()),
    );
    gh.factory<_i731.SetAppliedLayout>(
      () => _i731.SetAppliedLayout(gh<_i417.LayoutsRepository>()),
    );
    gh.factory<_i731.RemoveAppliedLayout>(
      () => _i731.RemoveAppliedLayout(gh<_i417.LayoutsRepository>()),
    );
    gh.factory<_i998.DeleteLayout>(
      () => _i998.DeleteLayout(gh<_i417.LayoutsRepository>()),
    );
    gh.factory<_i238.GetLayouts>(
      () => _i238.GetLayouts(gh<_i417.LayoutsRepository>()),
    );
    gh.factory<_i854.SaveLayout>(
      () => _i854.SaveLayout(gh<_i417.LayoutsRepository>()),
    );
    gh.factory<_i734.ToggleFavoriteLayout>(
      () => _i734.ToggleFavoriteLayout(gh<_i417.LayoutsRepository>()),
    );
    gh.lazySingleton<_i29.PlatformChannel>(
      () => registerModule.permissionsChannel,
      instanceName: 'permissionsChannel',
    );
    gh.lazySingleton<_i480.PermissionsPlatformDatasource>(
      () => _i480.PermissionsPlatformDatasourceImpl(
        gh<_i29.PlatformChannel>(instanceName: 'permissionsChannel'),
      ),
    );
    gh.lazySingleton<_i553.WorkspacesLocalDatasource>(
      () => _i553.WorkspacesLocalDatasourceImpl(gh<_i110.AppDatabase>()),
    );
    gh.lazySingleton<_i1071.SettingsLocalDatasource>(
      () => _i1071.SettingsLocalDatasourceImpl(gh<_i110.AppDatabase>()),
    );
    gh.lazySingleton<_i836.WorkspacePlatformDatasource>(
      () => _i836.WorkspacePlatformDatasourceImpl(
        gh<_i29.PlatformChannel>(instanceName: 'workspaceChannel'),
      ),
    );
    gh.lazySingleton<_i569.AppliedLayoutsCubit>(
      () => _i569.AppliedLayoutsCubit(
        gh<_i731.GetAppliedLayouts>(),
        gh<_i731.SetAppliedLayout>(),
        gh<_i731.RemoveAppliedLayout>(),
      ),
    );
    gh.lazySingleton<_i831.MonitorProfilesRepository>(
      () => _i620.MonitorProfilesRepositoryImpl(
        gh<_i320.MonitorProfilesLocalDatasource>(),
      ),
    );
    gh.lazySingleton<_i199.RulesRepository>(
      () => _i330.RulesRepositoryImpl(
        gh<_i538.RulesLocalDatasource>(),
        gh<_i649.PlatformEventChannel>(instanceName: 'workspaceEventsChannel'),
        gh<_i29.PlatformChannel>(instanceName: 'workspaceChannel'),
      ),
    );
    gh.lazySingleton<_i574.SystemPlatformDatasource>(
      () => _i574.SystemPlatformDatasourceImpl(
        gh<_i29.PlatformChannel>(instanceName: 'appChannel'),
      ),
    );
    gh.factory<_i750.DeleteRule>(
      () => _i750.DeleteRule(gh<_i199.RulesRepository>()),
    );
    gh.factory<_i670.GetRules>(
      () => _i670.GetRules(gh<_i199.RulesRepository>()),
    );
    gh.factory<_i443.SaveRule>(
      () => _i443.SaveRule(gh<_i199.RulesRepository>()),
    );
    gh.lazySingleton<_i141.WindowPositionsRepository>(
      () => _i1033.WindowPositionsRepositoryImpl(
        gh<_i422.WindowPositionsLocalDatasource>(),
      ),
    );
    gh.lazySingleton<_i698.WindowsPlatformDatasource>(
      () => _i698.WindowsPlatformDatasourceImpl(
        gh<_i29.PlatformChannel>(instanceName: 'windowsChannel'),
      ),
    );
    gh.factory<_i493.GetMonitorProfiles>(
      () => _i493.GetMonitorProfiles(gh<_i831.MonitorProfilesRepository>()),
    );
    gh.factory<_i493.SaveMonitorProfile>(
      () => _i493.SaveMonitorProfile(gh<_i831.MonitorProfilesRepository>()),
    );
    gh.factory<_i493.DeleteMonitorProfile>(
      () => _i493.DeleteMonitorProfile(gh<_i831.MonitorProfilesRepository>()),
    );
    gh.lazySingleton<_i329.PermissionsRepository>(
      () => _i372.PermissionsRepositoryImpl(
        gh<_i480.PermissionsPlatformDatasource>(),
      ),
    );
    gh.lazySingleton<_i271.WindowsRepository>(
      () => _i572.WindowsRepositoryImpl(gh<_i698.WindowsPlatformDatasource>()),
    );
    gh.lazySingleton<_i640.MonitorsRepository>(
      () =>
          _i336.MonitorsRepositoryImpl(gh<_i204.MonitorsPlatformDatasource>()),
    );
    gh.lazySingleton<_i243.LicenseRemoteDatasource>(
      () => _i243.LicenseRemoteDatasourceImpl(gh<_i519.Client>()),
    );
    gh.lazySingleton<_i768.WorkspacesRepository>(
      () =>
          _i89.WorkspacesRepositoryImpl(gh<_i553.WorkspacesLocalDatasource>()),
    );
    gh.lazySingleton<_i111.HistoryRepository>(
      () => _i487.HistoryRepositoryImpl(gh<_i619.HistoryLocalDatasource>()),
    );
    gh.lazySingleton<_i183.ShortcutsPlatformDatasource>(
      () => _i183.ShortcutsPlatformDatasourceImpl(
        gh<_i29.PlatformChannel>(instanceName: 'shortcutsChannel'),
        gh<_i649.PlatformEventChannel>(instanceName: 'shortcutsEventsChannel'),
      ),
    );
    gh.lazySingleton<_i549.SystemIntegrationRepository>(
      () => _i788.SystemIntegrationRepositoryImpl(
        gh<_i574.SystemPlatformDatasource>(),
      ),
    );
    gh.lazySingleton<_i1063.LicenseRepository>(
      () => _i922.LicenseRepositoryImpl(
        gh<_i308.LicenseLocalDatasource>(),
        gh<_i243.LicenseRemoteDatasource>(),
        gh<_i432.EntitlementVerifier>(),
      ),
    );
    gh.lazySingleton<_i335.SettingsRepository>(
      () => _i84.SettingsRepositoryImpl(gh<_i1071.SettingsLocalDatasource>()),
    );
    gh.lazySingleton<_i424.AppsLauncherRepository>(
      () => _i226.AppsLauncherRepositoryImpl(
        gh<_i836.WorkspacePlatformDatasource>(),
      ),
    );
    gh.lazySingleton<_i831.ShortcutsRepository>(
      () => _i611.ShortcutsRepositoryImpl(
        gh<_i183.ShortcutsPlatformDatasource>(),
      ),
    );
    gh.factory<_i178.GetPermissionsStatus>(
      () => _i178.GetPermissionsStatus(gh<_i329.PermissionsRepository>()),
    );
    gh.factory<_i953.OpenPermissionSettings>(
      () => _i953.OpenPermissionSettings(gh<_i329.PermissionsRepository>()),
    );
    gh.factory<_i1046.RequestAccessibility>(
      () => _i1046.RequestAccessibility(gh<_i329.PermissionsRepository>()),
    );
    gh.factory<_i563.ApplySystemIntegration>(
      () =>
          _i563.ApplySystemIntegration(gh<_i549.SystemIntegrationRepository>()),
    );
    gh.factory<_i244.ApplyLayout>(
      () => _i244.ApplyLayout(gh<_i271.WindowsRepository>()),
    );
    gh.factory<_i561.CenterWindow>(
      () => _i561.CenterWindow(gh<_i271.WindowsRepository>()),
    );
    gh.factory<_i113.FocusWindow>(
      () => _i113.FocusWindow(gh<_i271.WindowsRepository>()),
    );
    gh.factory<_i862.GetWindows>(
      () => _i862.GetWindows(gh<_i271.WindowsRepository>()),
    );
    gh.factory<_i148.MaximizeWindow>(
      () => _i148.MaximizeWindow(gh<_i271.WindowsRepository>()),
    );
    gh.factory<_i855.MoveResizeWindow>(
      () => _i855.MoveResizeWindow(gh<_i271.WindowsRepository>()),
    );
    gh.factory<_i290.DeleteWorkspace>(
      () => _i290.DeleteWorkspace(gh<_i768.WorkspacesRepository>()),
    );
    gh.factory<_i237.GetWorkspaces>(
      () => _i237.GetWorkspaces(gh<_i768.WorkspacesRepository>()),
    );
    gh.factory<_i9.SaveWorkspace>(
      () => _i9.SaveWorkspace(gh<_i768.WorkspacesRepository>()),
    );
    gh.factory<_i924.ApplyRuleToWindow>(
      () => _i924.ApplyRuleToWindow(
        gh<_i271.WindowsRepository>(),
        gh<_i417.LayoutsRepository>(),
        gh<_i561.CenterWindow>(),
        gh<_i148.MaximizeWindow>(),
      ),
    );
    gh.factory<_i33.GetMonitors>(
      () => _i33.GetMonitors(gh<_i640.MonitorsRepository>()),
    );
    gh.factory<_i288.WatchMonitors>(
      () => _i288.WatchMonitors(gh<_i640.MonitorsRepository>()),
    );
    gh.factory<_i472.ExportBackup>(
      () => _i472.ExportBackup(
        gh<_i417.LayoutsRepository>(),
        gh<_i768.WorkspacesRepository>(),
        gh<_i199.RulesRepository>(),
        gh<_i335.SettingsRepository>(),
      ),
    );
    gh.factory<_i744.ImportBackup>(
      () => _i744.ImportBackup(
        gh<_i417.LayoutsRepository>(),
        gh<_i768.WorkspacesRepository>(),
        gh<_i199.RulesRepository>(),
        gh<_i335.SettingsRepository>(),
      ),
    );
    gh.factory<_i618.GetHistory>(
      () => _i618.GetHistory(gh<_i111.HistoryRepository>()),
    );
    gh.factory<_i618.AddHistoryEntry>(
      () => _i618.AddHistoryEntry(gh<_i111.HistoryRepository>()),
    );
    gh.factory<_i618.ClearHistory>(
      () => _i618.ClearHistory(gh<_i111.HistoryRepository>()),
    );
    gh.lazySingleton<_i875.PermissionsCubit>(
      () => _i875.PermissionsCubit(
        gh<_i178.GetPermissionsStatus>(),
        gh<_i1046.RequestAccessibility>(),
        gh<_i953.OpenPermissionSettings>(),
      ),
    );
    gh.factory<_i948.ActivateLicense>(
      () => _i948.ActivateLicense(gh<_i1063.LicenseRepository>()),
    );
    gh.factory<_i1039.DeactivateLicense>(
      () => _i1039.DeactivateLicense(gh<_i1063.LicenseRepository>()),
    );
    gh.factory<_i726.GetLicense>(
      () => _i726.GetLicense(gh<_i1063.LicenseRepository>()),
    );
    gh.factory<_i372.RefreshLicense>(
      () => _i372.RefreshLicense(gh<_i1063.LicenseRepository>()),
    );
    gh.lazySingleton<_i431.HistoryCubit>(
      () =>
          _i431.HistoryCubit(gh<_i618.GetHistory>(), gh<_i618.ClearHistory>()),
    );
    gh.factory<_i122.GetSettings>(
      () => _i122.GetSettings(gh<_i335.SettingsRepository>()),
    );
    gh.factory<_i1066.SaveSettings>(
      () => _i1066.SaveSettings(gh<_i335.SettingsRepository>()),
    );
    gh.lazySingleton<_i731.SettingsCubit>(
      () => _i731.SettingsCubit(
        gh<_i122.GetSettings>(),
        gh<_i1066.SaveSettings>(),
        gh<_i563.ApplySystemIntegration>(),
      ),
    );
    gh.factory<_i45.ApplyWorkspace>(
      () => _i45.ApplyWorkspace(
        gh<_i417.LayoutsRepository>(),
        gh<_i271.WindowsRepository>(),
        gh<_i424.AppsLauncherRepository>(),
        gh<_i768.WorkspacesRepository>(),
      ),
    );
    gh.factory<_i69.RegisterShortcuts>(
      () => _i69.RegisterShortcuts(gh<_i831.ShortcutsRepository>()),
    );
    gh.factory<_i651.WatchShortcutPresses>(
      () => _i651.WatchShortcutPresses(gh<_i831.ShortcutsRepository>()),
    );
    gh.lazySingleton<_i485.LicenseCubit>(
      () => _i485.LicenseCubit(
        gh<_i726.GetLicense>(),
        gh<_i948.ActivateLicense>(),
        gh<_i372.RefreshLicense>(),
        gh<_i1039.DeactivateLicense>(),
      ),
    );
    gh.lazySingleton<_i607.UndoRedoCubit>(
      () => _i607.UndoRedoCubit(
        gh<_i862.GetWindows>(),
        gh<_i855.MoveResizeWindow>(),
      ),
    );
    gh.lazySingleton<_i935.MonitorsCubit>(
      () => _i935.MonitorsCubit(
        gh<_i33.GetMonitors>(),
        gh<_i288.WatchMonitors>(),
      ),
    );
    gh.lazySingleton<_i971.RulesCubit>(
      () => _i971.RulesCubit(
        gh<_i670.GetRules>(),
        gh<_i443.SaveRule>(),
        gh<_i750.DeleteRule>(),
        gh<_i924.ApplyRuleToWindow>(),
        gh<_i199.RulesRepository>(),
        gh<_i862.GetWindows>(),
        gh<_i935.MonitorsCubit>(),
        gh<_i731.SettingsCubit>(),
        gh<_i569.AppliedLayoutsCubit>(),
        gh<_i618.AddHistoryEntry>(),
      ),
    );
    gh.lazySingleton<_i466.WindowCloseService>(
      () => _i466.WindowCloseService(gh<_i731.SettingsCubit>()),
    );
    gh.lazySingleton<_i31.WindowsCubit>(
      () => _i31.WindowsCubit(
        gh<_i862.GetWindows>(),
        gh<_i33.GetMonitors>(),
        gh<_i113.FocusWindow>(),
        gh<_i561.CenterWindow>(),
        gh<_i148.MaximizeWindow>(),
        gh<_i731.SettingsCubit>(),
        gh<_i607.UndoRedoCubit>(),
      ),
    );
    gh.lazySingleton<_i422.WorkspacesCubit>(
      () => _i422.WorkspacesCubit(
        gh<_i237.GetWorkspaces>(),
        gh<_i9.SaveWorkspace>(),
        gh<_i290.DeleteWorkspace>(),
        gh<_i45.ApplyWorkspace>(),
        gh<_i935.MonitorsCubit>(),
        gh<_i731.SettingsCubit>(),
        gh<_i618.AddHistoryEntry>(),
      ),
    );
    gh.lazySingleton<_i103.WindowSnapService>(
      () => _i103.WindowSnapService(
        gh<_i731.SettingsCubit>(),
        gh<_i935.MonitorsCubit>(),
        gh<_i271.WindowsRepository>(),
      ),
    );
    gh.lazySingleton<_i408.RegionCycleService>(
      () => _i408.RegionCycleService(
        gh<_i731.SettingsCubit>(),
        gh<_i935.MonitorsCubit>(),
        gh<_i569.AppliedLayoutsCubit>(),
        gh<_i238.GetLayouts>(),
        gh<_i271.WindowsRepository>(),
      ),
    );
    gh.lazySingleton<_i108.SnapRegionsService>(
      () => _i108.SnapRegionsService(
        gh<_i731.SettingsCubit>(),
        gh<_i935.MonitorsCubit>(),
        gh<_i569.AppliedLayoutsCubit>(),
        gh<_i238.GetLayouts>(),
        gh<_i549.SystemIntegrationRepository>(),
      ),
    );
    gh.lazySingleton<_i539.LayoutsCubit>(
      () => _i539.LayoutsCubit(
        gh<_i238.GetLayouts>(),
        gh<_i734.ToggleFavoriteLayout>(),
        gh<_i998.DeleteLayout>(),
        gh<_i244.ApplyLayout>(),
        gh<_i854.SaveLayout>(),
        gh<_i862.GetWindows>(),
        gh<_i935.MonitorsCubit>(),
        gh<_i731.SettingsCubit>(),
        gh<_i607.UndoRedoCubit>(),
        gh<_i618.AddHistoryEntry>(),
        gh<_i569.AppliedLayoutsCubit>(),
      ),
    );
    gh.lazySingleton<_i1058.LayoutEditorCubit>(
      () => _i1058.LayoutEditorCubit(
        gh<_i854.SaveLayout>(),
        gh<_i539.LayoutsCubit>(),
      ),
    );
    gh.lazySingleton<_i41.BackupCubit>(
      () => _i41.BackupCubit(
        gh<_i472.ExportBackup>(),
        gh<_i744.ImportBackup>(),
        gh<_i539.LayoutsCubit>(),
        gh<_i422.WorkspacesCubit>(),
        gh<_i971.RulesCubit>(),
        gh<_i731.SettingsCubit>(),
      ),
    );
    gh.lazySingleton<_i752.AutoRestoreService>(
      () => _i752.AutoRestoreService(
        gh<_i141.WindowPositionsRepository>(),
        gh<_i199.RulesRepository>(),
        gh<_i862.GetWindows>(),
        gh<_i855.MoveResizeWindow>(),
        gh<_i31.WindowsCubit>(),
        gh<_i935.MonitorsCubit>(),
        gh<_i971.RulesCubit>(),
      ),
    );
    gh.lazySingleton<_i900.StatusBarService>(
      () => _i900.StatusBarService(
        gh<_i29.PlatformChannel>(instanceName: 'appChannel'),
        gh<_i649.PlatformEventChannel>(instanceName: 'appEventsChannel'),
        gh<_i539.LayoutsCubit>(),
        gh<_i422.WorkspacesCubit>(),
        gh<_i351.NavigationCubit>(),
      ),
    );
    gh.lazySingleton<_i588.MonitorProfilesCubit>(
      () => _i588.MonitorProfilesCubit(
        gh<_i493.GetMonitorProfiles>(),
        gh<_i493.SaveMonitorProfile>(),
        gh<_i493.DeleteMonitorProfile>(),
        gh<_i935.MonitorsCubit>(),
        gh<_i422.WorkspacesCubit>(),
        gh<_i539.LayoutsCubit>(),
      ),
    );
    gh.lazySingleton<_i420.ShortcutsCubit>(
      () => _i420.ShortcutsCubit(
        gh<_i69.RegisterShortcuts>(),
        gh<_i651.WatchShortcutPresses>(),
        gh<_i539.LayoutsCubit>(),
        gh<_i422.WorkspacesCubit>(),
        gh<_i731.SettingsCubit>(),
        gh<_i569.AppliedLayoutsCubit>(),
        gh<_i408.RegionCycleService>(),
        gh<_i103.WindowSnapService>(),
      ),
    );
    return this;
  }
}

class _$RegisterModule extends _i132.RegisterModule {}
