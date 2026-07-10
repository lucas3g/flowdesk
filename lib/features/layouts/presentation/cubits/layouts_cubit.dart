import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/usecases/usecase.dart';
import '../../../history/domain/entities/history_entry.dart';
import '../../../history/domain/usecases/history_usecases.dart';
import '../../../monitors/domain/entities/monitor.dart';
import '../../../monitors/presentation/cubits/monitors_cubit.dart';
import '../../../settings/presentation/cubits/settings_cubit.dart';
import '../../../windows/domain/entities/managed_window.dart';
import '../../../windows/domain/usecases/get_windows.dart';
import '../../../windows/presentation/cubits/undo_redo_cubit.dart';
import '../../domain/entities/layout.dart';
import '../../domain/usecases/apply_layout.dart';
import '../../domain/usecases/delete_layout.dart';
import '../../domain/usecases/get_layouts.dart';
import '../../domain/usecases/save_layout.dart';
import '../../domain/usecases/toggle_favorite_layout.dart';
import 'layouts_state.dart';

/// Galeria de layouts: carregamento, filtros, favoritos e aplicação real
/// nas janelas do monitor ativo.
@lazySingleton
class LayoutsCubit extends Cubit<LayoutsState> {
  LayoutsCubit(
    this._getLayouts,
    this._toggleFavorite,
    this._deleteLayout,
    this._applyLayout,
    this._saveLayout,
    this._getWindows,
    this._monitorsCubit,
    this._settingsCubit,
    this._undoRedoCubit,
    this._addHistoryEntry,
  ) : super(const LayoutsState());

  final GetLayouts _getLayouts;
  final ToggleFavoriteLayout _toggleFavorite;
  final DeleteLayout _deleteLayout;
  final ApplyLayout _applyLayout;
  final SaveLayout _saveLayout;
  final GetWindows _getWindows;
  final MonitorsCubit _monitorsCubit;
  final SettingsCubit _settingsCubit;
  final UndoRedoCubit _undoRedoCubit;
  final AddHistoryEntry _addHistoryEntry;

  Future<void> load() async {
    final result = await _getLayouts(const NoParams());
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: LayoutsStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (layouts) => emit(
        state.copyWith(status: LayoutsStatus.ready, layouts: layouts),
      ),
    );
  }

  void setFilter(LayoutsFilter filter) => emit(state.copyWith(filter: filter));

  void search(String query) => emit(state.copyWith(query: query));

  /// Define o monitor de destino do seletor (null = automático).
  void setTargetMonitor(int? monitorId) =>
      emit(state.copyWith(targetMonitorId: () => monitorId));

  Future<void> toggleFavorite(Layout layout) async {
    await _toggleFavorite(
      ToggleFavoriteParams(
        layoutId: layout.id,
        isFavorite: !layout.isFavorite,
      ),
    );
    await load();
  }

  /// Altera o atalho global do layout (null remove).
  Future<void> setShortcut(Layout layout, String? shortcut) async {
    await _saveLayout(layout.copyWith(shortcut: () => shortcut));
    await load();
  }

  Future<void> delete(Layout layout) async {
    if (layout.isPreset) return;
    await _deleteLayout(layout.id);
    await load();
  }

  /// Aplica o layout às janelas do monitor da janela em foco
  /// (ou do monitor principal).
  Future<void> apply(Layout layout) async {
    // A área útil muda sem aviso confiável (Dock/menu bar migram de tela),
    // então a geometria é recarregada do nativo no momento da aplicação.
    await _monitorsCubit.refresh();
    final windowsResult = await _getWindows(const NoParams());

    await windowsResult.fold(
      (failure) async => emit(state.copyWith(feedback: failure.message)),
      (windows) async {
        final monitor = _targetMonitor(windows);
        if (monitor == null) {
          emit(state.copyWith(feedback: 'Nenhum monitor detectado.'));
          return;
        }

        // Apps associados a regiões são trazidos de qualquer monitor;
        // as regiões livres usam as janelas já no monitor alvo.
        final associatedBundleIds = layout.regions
            .where((region) => region.hasApp)
            .map((region) => region.appBundleId)
            .toSet();
        final targets = windows
            .where(
              (window) =>
                  window.monitorId == monitor.id ||
                  associatedBundleIds.contains(window.bundleId),
            )
            .toList(growable: false);
        if (targets.isEmpty) {
          emit(
            state.copyWith(feedback: 'Nenhuma janela para posicionar.'),
          );
          return;
        }

        // Permite desfazer a movimentação (⌘Z).
        _undoRedoCubit.pushSnapshot(targets);

        final settings = _settingsCubit.state.settings;
        final result = await _applyLayout(
          ApplyLayoutParams(
            layout: layout,
            monitor: monitor,
            windows: targets,
            gap: settings.windowGap,
            margin: settings.screenMargin,
          ),
        );

        await result.fold(
          (failure) async => emit(state.copyWith(feedback: failure.message)),
          (applied) async {
            // Registra como último layout aplicado — o SnapRegionsService
            // reage à mudança e atualiza as zonas de encaixe no nativo.
            await _settingsCubit.setLastAppliedLayout(layout.id, monitor.id);
            await _addHistoryEntry(
              AddHistoryParams(
                type: HistoryEntryType.layout,
                title: "Aplicou '${layout.name}'",
                subtitle:
                    '$applied ${applied == 1 ? 'janela' : 'janelas'}'
                    ' no monitor ${monitor.name}',
              ),
            );
            emit(
              state.copyWith(
                feedback:
                    "Layout '${layout.name}' aplicado a $applied "
                    '${applied == 1 ? 'janela' : 'janelas'}.',
              ),
            );
          },
        );
      },
    );
  }

  /// Limpa a mensagem transitória após exibição.
  void clearFeedback() {
    if (state.feedback != null) emit(state.copyWith());
  }

  Monitor? _targetMonitor(List<ManagedWindow> windows) {
    final monitors = _monitorsCubit.state.monitors;
    if (monitors.isEmpty) return null;

    // Monitor escolhido explicitamente no seletor da galeria.
    if (state.targetMonitorId != null) {
      for (final monitor in monitors) {
        if (monitor.id == state.targetMonitorId) return monitor;
      }
    }

    final focused = windows.where((window) => window.isFocused);
    if (focused.isNotEmpty) {
      for (final monitor in monitors) {
        if (monitor.id == focused.first.monitorId) return monitor;
      }
    }
    return monitors.firstWhere(
      (monitor) => monitor.isPrimary,
      orElse: () => monitors.first,
    );
  }
}
