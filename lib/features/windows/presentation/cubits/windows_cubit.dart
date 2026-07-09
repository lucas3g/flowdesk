import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/usecases/usecase.dart';
import '../../../monitors/domain/entities/monitor.dart';
import '../../../monitors/domain/usecases/get_monitors.dart';
import '../../../settings/presentation/cubits/settings_cubit.dart';
import '../../domain/entities/managed_window.dart';
import '../../domain/usecases/center_window.dart';
import '../../domain/usecases/focus_window.dart';
import '../../domain/usecases/get_windows.dart';
import '../../domain/usecases/maximize_window.dart';
import 'undo_redo_cubit.dart';
import 'windows_state.dart';

/// Lista e manipula as janelas abertas; usa a margem configurada nas
/// preferências ao maximizar.
@lazySingleton
class WindowsCubit extends Cubit<WindowsState> {
  WindowsCubit(
    this._getWindows,
    this._getMonitors,
    this._focusWindow,
    this._centerWindow,
    this._maximizeWindow,
    this._settingsCubit,
    this._undoRedoCubit,
  ) : super(const WindowsState());

  final GetWindows _getWindows;
  final GetMonitors _getMonitors;
  final FocusWindow _focusWindow;
  final CenterWindow _centerWindow;
  final MaximizeWindow _maximizeWindow;
  final SettingsCubit _settingsCubit;
  final UndoRedoCubit _undoRedoCubit;

  /// Recarrega janelas e monitores.
  Future<void> refresh() async {
    final windowsResult = await _getWindows(const NoParams());
    final monitorsResult = await _getMonitors(const NoParams());

    windowsResult.fold(
      (failure) => emit(
        state.copyWith(
          status: WindowsStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (windows) => emit(
        state.copyWith(
          status: WindowsStatus.ready,
          windows: windows,
          monitors: monitorsResult.getOrElse((_) => state.monitors),
        ),
      ),
    );
  }

  void selectMonitor(int? monitorId) {
    emit(state.copyWith(selectedMonitorId: () => monitorId));
  }

  void search(String query) {
    emit(state.copyWith(query: query));
  }

  Future<void> focus(ManagedWindow window) async {
    await _focusWindow(window);
    await refresh();
  }

  Future<void> center(ManagedWindow window) async {
    final monitor = _monitorOf(window);
    if (monitor == null) return;
    _undoRedoCubit.pushSnapshot([window]);
    await _centerWindow(CenterParams(window: window, monitor: monitor));
    await refresh();
  }

  Future<void> maximize(ManagedWindow window) async {
    final monitor = _monitorOf(window);
    if (monitor == null) return;
    _undoRedoCubit.pushSnapshot([window]);
    await _maximizeWindow(
      MaximizeParams(
        window: window,
        monitor: monitor,
        margin: _settingsCubit.state.settings.screenMargin,
      ),
    );
    await refresh();
  }

  Monitor? _monitorOf(ManagedWindow window) {
    for (final monitor in state.monitors) {
      if (monitor.id == window.monitorId) return monitor;
    }
    return state.monitors.isEmpty ? null : state.monitors.first;
  }
}
