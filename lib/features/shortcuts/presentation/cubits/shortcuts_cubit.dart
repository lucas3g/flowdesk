import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/services/region_cycle_service.dart';
import '../../../layouts/presentation/cubits/applied_layouts_cubit.dart';
import '../../../layouts/presentation/cubits/layouts_cubit.dart';
import '../../../layouts/presentation/cubits/layouts_state.dart';
import '../../../settings/presentation/cubits/settings_cubit.dart';
import '../../../settings/presentation/cubits/settings_state.dart';
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
    this._settingsCubit,
    this._appliedLayoutsCubit,
    this._regionCycleService,
  ) : super(const ShortcutsState());

  final RegisterShortcuts _registerShortcuts;
  final WatchShortcutPresses _watchPresses;
  final LayoutsCubit _layoutsCubit;
  final WorkspacesCubit _workspacesCubit;
  final SettingsCubit _settingsCubit;
  final AppliedLayoutsCubit _appliedLayoutsCubit;
  final RegionCycleService _regionCycleService;

  StreamSubscription<int>? _pressesSubscription;
  StreamSubscription<LayoutsState>? _layoutsSubscription;
  StreamSubscription<WorkspacesState>? _workspacesSubscription;
  StreamSubscription<SettingsState>? _settingsSubscription;
  StreamSubscription<Map<String, int>>? _appliedSubscription;

  /// Sincroniza agora e re-sincroniza quando layouts/workspaces/settings
  /// mudarem (um layout aplicado ativa os atalhos de ciclo de região).
  Future<void> start() async {
    _pressesSubscription ??= _watchPresses().listen(_onPressed);
    _layoutsSubscription ??= _layoutsCubit.stream.listen((_) => sync());
    _workspacesSubscription ??= _workspacesCubit.stream.listen((_) => sync());
    _settingsSubscription ??= _settingsCubit.stream.listen((_) => sync());
    _appliedSubscription ??= _appliedLayoutsCubit.stream.listen(
      (_) => sync(),
    );
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

    // Atalhos de ciclo de região (⌘⌥←/→, Ctrl+Win+←/→ no Windows) só ficam
    // registrados enquanto algum monitor tem layout aplicado com regiões —
    // sem layout, os apps recebem essas combinações normalmente.
    final appliedIds = _appliedLayoutsCubit.state.values.toSet();
    final hasAppliedRegions = _layoutsCubit.state.layouts.any(
      (layout) => appliedIds.contains(layout.id) && layout.regions.isNotEmpty,
    );
    if (hasAppliedRegions) {
      bindings
        ..add(
          ShortcutBinding(
            id: id++,
            combo: HotkeyCombo.cycleRegionPrev,
            type: ShortcutActionType.cycleRegionPrev,
            targetId: 0,
            description: 'Mover janela para a região anterior',
          ),
        )
        ..add(
          ShortcutBinding(
            id: id++,
            combo: HotkeyCombo.cycleRegionNext,
            type: ShortcutActionType.cycleRegionNext,
            targetId: 0,
            description: 'Mover janela para a próxima região',
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
      case ShortcutActionType.cycleRegionPrev:
        _regionCycleService.cycle(CycleDirection.previous);
      case ShortcutActionType.cycleRegionNext:
        _regionCycleService.cycle(CycleDirection.next);
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
    await _settingsSubscription?.cancel();
    return super.close();
  }
}
