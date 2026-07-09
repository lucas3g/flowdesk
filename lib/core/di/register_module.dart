import 'package:injectable/injectable.dart';

import '../constants/app_constants.dart';
import '../platform/platform_channel.dart';
import '../platform/platform_event_channel.dart';
import '../services/database/app_database.dart';

/// Registra dependências de terceiros/infraestrutura que não podem ser
/// anotadas diretamente com Injectable.
@module
abstract class RegisterModule {
  @lazySingleton
  AppDatabase get database => AppDatabase();

  @Named('permissionsChannel')
  @lazySingleton
  PlatformChannel get permissionsChannel =>
      PlatformChannel(AppConstants.permissionsChannel);

  @Named('monitorsChannel')
  @lazySingleton
  PlatformChannel get monitorsChannel =>
      PlatformChannel(AppConstants.monitorsChannel);

  @Named('monitorsEventsChannel')
  @lazySingleton
  PlatformEventChannel get monitorsEventsChannel =>
      PlatformEventChannel(AppConstants.monitorsEventsChannel);

  @Named('windowsChannel')
  @lazySingleton
  PlatformChannel get windowsChannel =>
      PlatformChannel(AppConstants.windowsChannel);

  @Named('workspaceChannel')
  @lazySingleton
  PlatformChannel get workspaceChannel =>
      PlatformChannel(AppConstants.workspaceChannel);

  @Named('workspaceEventsChannel')
  @lazySingleton
  PlatformEventChannel get workspaceEventsChannel =>
      PlatformEventChannel(AppConstants.workspaceEventsChannel);

  @Named('appChannel')
  @lazySingleton
  PlatformChannel get appChannel => PlatformChannel(AppConstants.appChannel);

  @Named('appEventsChannel')
  @lazySingleton
  PlatformEventChannel get appEventsChannel =>
      PlatformEventChannel(AppConstants.appEventsChannel);

  @Named('shortcutsChannel')
  @lazySingleton
  PlatformChannel get shortcutsChannel =>
      PlatformChannel(AppConstants.shortcutsChannel);

  @Named('shortcutsEventsChannel')
  @lazySingleton
  PlatformEventChannel get shortcutsEventsChannel =>
      PlatformEventChannel(AppConstants.shortcutsEventsChannel);
}
