import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:window_manager/window_manager.dart';

import 'core/constants/app_constants.dart';
import 'core/di/injection.dart';
import 'core/services/auto_restore_service.dart';
import 'core/services/status_bar_service.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/shell/app_shell.dart';
import 'features/layouts/presentation/cubits/layouts_cubit.dart';
import 'features/monitors/presentation/cubits/monitors_cubit.dart';
import 'features/monitors/presentation/cubits/monitor_profiles_cubit.dart';
import 'features/permissions/presentation/cubits/permissions_cubit.dart';
import 'features/rules/presentation/cubits/rules_cubit.dart';
import 'features/shortcuts/presentation/cubits/shortcuts_cubit.dart';
import 'features/workspaces/presentation/cubits/workspaces_cubit.dart';
import 'features/settings/presentation/cubits/settings_cubit.dart';
import 'features/settings/presentation/cubits/settings_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  await configureDependencies();

  // Estado global inicial: preferências persistidas e permissões do sistema.
  await getIt<SettingsCubit>().load();
  unawaited(getIt<PermissionsCubit>().startMonitoring());
  unawaited(getIt<MonitorsCubit>().start());

  // Layouts/workspaces carregados no boot alimentam hotkeys e menu bar.
  await getIt<LayoutsCubit>().load();
  await getIt<WorkspacesCubit>().load();
  unawaited(getIt<ShortcutsCubit>().start());
  unawaited(getIt<StatusBarService>().start());
  unawaited(getIt<RulesCubit>().start());
  unawaited(getIt<MonitorProfilesCubit>().start());
  getIt<AutoRestoreService>().start();

  const windowOptions = WindowOptions(
    size: Size(1440, 900),
    minimumSize: Size(1180, 720),
    center: true,
    titleBarStyle: TitleBarStyle.hidden,
    title: AppConstants.appName,
  );
  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(FlowDeskApp());
}

class FlowDeskApp extends StatelessWidget {
  FlowDeskApp({super.key});

  final SettingsCubit _settingsCubit = getIt<SettingsCubit>();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      bloc: _settingsCubit,
      buildWhen: (previous, current) => previous.themeMode != current.themeMode,
      builder: (context, state) {
        return MaterialApp(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: state.themeMode,
          home: AppShell(),
        );
      },
    );
  }
}
