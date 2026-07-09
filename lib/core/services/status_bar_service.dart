import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:window_manager/window_manager.dart';

import '../../features/layouts/presentation/cubits/layouts_cubit.dart';
import '../../features/workspaces/presentation/cubits/workspaces_cubit.dart';
import '../platform/platform_channel.dart';
import '../platform/platform_event_channel.dart';
import '../routing/app_screen.dart';
import '../routing/navigation_cubit.dart';

/// Alimenta o menu da barra de menus do macOS com os layouts/workspaces
/// atuais e despacha as ações escolhidas pelo usuário no menu nativo.
@lazySingleton
class StatusBarService {
  StatusBarService(
    @Named('appChannel') this._channel,
    @Named('appEventsChannel') this._eventsChannel,
    this._layoutsCubit,
    this._workspacesCubit,
    this._navigationCubit,
  );

  final PlatformChannel _channel;
  final PlatformEventChannel _eventsChannel;
  final LayoutsCubit _layoutsCubit;
  final WorkspacesCubit _workspacesCubit;
  final NavigationCubit _navigationCubit;

  StreamSubscription<Object?>? _eventsSubscription;
  StreamSubscription<Object?>? _layoutsSubscription;
  StreamSubscription<Object?>? _workspacesSubscription;

  /// Publica o menu atual e passa a reagir a mudanças e ações.
  Future<void> start() async {
    _eventsSubscription ??= _eventsChannel.receive<Object?>().listen(_onEvent);
    _layoutsSubscription ??= _layoutsCubit.stream.listen((_) => _pushMenu());
    _workspacesSubscription ??= _workspacesCubit.stream.listen(
      (_) => _pushMenu(),
    );
    await _pushMenu();
  }

  Future<void> _pushMenu() async {
    await _channel.invoke<void>('setStatusBarMenu', {
      'layouts': [
        for (final layout in _layoutsCubit.state.layouts)
          {
            'id': layout.id,
            'name': layout.name,
            'shortcut': layout.shortcut ?? '',
          },
      ],
      'workspaces': [
        for (final workspace in _workspacesCubit.state.workspaces)
          {
            'id': workspace.id,
            'name': workspace.name,
            'emoji': workspace.emoji,
          },
      ],
    });
  }

  Future<void> _onEvent(Object? event) async {
    if (event is! Map) return;
    final type = event['type'];
    final id = event['id'] as int?;

    switch (type) {
      case 'applyLayout':
        for (final layout in _layoutsCubit.state.layouts) {
          if (layout.id == id) {
            await _layoutsCubit.apply(layout);
            return;
          }
        }
      case 'applyWorkspace':
        for (final workspace in _workspacesCubit.state.workspaces) {
          if (workspace.id == id) {
            await _workspacesCubit.apply(workspace);
            return;
          }
        }
      case 'openPreferences':
        _navigationCubit.navigate(AppScreen.settings);
        await windowManager.show();
        await windowManager.focus();
      case 'openApp':
        await windowManager.show();
        await windowManager.focus();
    }
  }
}
