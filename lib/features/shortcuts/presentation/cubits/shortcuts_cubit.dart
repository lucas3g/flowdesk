import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../layouts/presentation/cubits/layouts_cubit.dart';
import '../../../layouts/presentation/cubits/layouts_state.dart';
import '../../../workspaces/presentation/cubits/workspaces_cubit.dart';
import '../../../workspaces/presentation/cubits/workspaces_state.dart';
import '../../domain/entities/hotkey_combo.dart';
import '../../domain/entities/shortcut_binding.dart';
import '../../domain/usecases/register_shortcuts.dart';
import '../../domain/usecases/watch_shortcut_presses.dart';
import 'shortcuts_state.dart';

/// Mantém os hotkeys globais sincronizados com os atalhos definidos em
/// layouts e workspaces, e despacha a ação quando um deles é acionado
/// (mesmo com o app em segundo plano).
@lazySingleton
class ShortcutsCubit extends Cubit<ShortcutsState> {
  ShortcutsCubit(
    this._registerShortcuts,
    this._watchPresses,
    this._layoutsCubit,
    this._workspacesCubit,
  ) : super(const ShortcutsState());

  final RegisterShortcuts _registerShortcuts;
  final WatchShortcutPresses _watchPresses;
  final LayoutsCubit _layoutsCubit;
  final WorkspacesCubit _workspacesCubit;

  StreamSubscription<int>? _pressesSubscription;
  StreamSubscription<LayoutsState>? _layoutsSubscription;
  StreamSubscription<WorkspacesState>? _workspacesSubscription;

  /// Sincroniza agora e re-sincroniza quando layouts/workspaces mudarem.
  Future<void> start() async {
    _pressesSubscription ??= _watchPresses().listen(_onPressed);
    _layoutsSubscription ??= _layoutsCubit.stream.listen((_) => sync());
    _workspacesSubscription ??= _workspacesCubit.stream.listen((_) => sync());
    await sync();
  }

  /// Reconstrói os bindings a partir dos atalhos salvos e registra no macOS.
  Future<void> sync() async {
    final bindings = <ShortcutBinding>[];
    var id = 1;

    for (final layout in _layoutsCubit.state.layouts) {
      final combo = HotkeyCombo.tryParse(layout.shortcut);
      if (combo == null) continue;
      bindings.add(
        ShortcutBinding(
          id: id++,
          combo: combo,
          type: ShortcutActionType.applyLayout,
          targetId: layout.id,
          description: layout.name,
        ),
      );
    }

    for (final workspace in _workspacesCubit.state.workspaces) {
      final combo = HotkeyCombo.tryParse(workspace.shortcut);
      if (combo == null) continue;
      bindings.add(
        ShortcutBinding(
          id: id++,
          combo: combo,
          type: ShortcutActionType.applyWorkspace,
          targetId: workspace.id,
          description: workspace.name,
        ),
      );
    }

    if (_sameBindings(bindings, state.bindings)) return;

    final result = await _registerShortcuts(bindings);
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: ShortcutsStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (_) => emit(
        state.copyWith(status: ShortcutsStatus.ready, bindings: bindings),
      ),
    );
  }

  void _onPressed(int id) {
    ShortcutBinding? binding;
    for (final candidate in state.bindings) {
      if (candidate.id == id) {
        binding = candidate;
        break;
      }
    }
    if (binding == null) return;

    switch (binding.type) {
      case ShortcutActionType.applyLayout:
        for (final layout in _layoutsCubit.state.layouts) {
          if (layout.id == binding.targetId) {
            _layoutsCubit.apply(layout);
            return;
          }
        }
      case ShortcutActionType.applyWorkspace:
        for (final workspace in _workspacesCubit.state.workspaces) {
          if (workspace.id == binding.targetId) {
            _workspacesCubit.apply(workspace);
            return;
          }
        }
    }
  }

  bool _sameBindings(List<ShortcutBinding> a, List<ShortcutBinding> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].combo != b[i].combo ||
          a[i].type != b[i].type ||
          a[i].targetId != b[i].targetId) {
        return false;
      }
    }
    return true;
  }

  @override
  Future<void> close() async {
    await _pressesSubscription?.cancel();
    await _layoutsSubscription?.cancel();
    await _workspacesSubscription?.cancel();
    return super.close();
  }
}
