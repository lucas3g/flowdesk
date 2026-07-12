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
import 'applied_layouts_cubit.dart';
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
    this._appliedLayoutsCubit,
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
  final AppliedLayoutsCubit _appliedLayoutsCubit;

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
        state.copyWith(
          status: LayoutsStatus.ready,
          layouts: layouts,
          // O seletor reflete o monitor padrão persistido.
          targetMonitorId: () =>
              _settingsCubit.state.settings.preferredMonitorId,
        ),
      ),
    );
  }

  void setFilter(LayoutsFilter filter) => emit(state.copyWith(filter: filter));

  void search(String query) => emit(state.copyWith(query: query));

  /// Define o monitor de destino do seletor (null = automático) e o
  /// persiste como padrão para as próximas aplicações.
  Future<void> setTargetMonitor(int? monitorId) async {
    emit(state.copyWith(targetMonitorId: () => monitorId));
    await _settingsCubit.setPreferredMonitor(monitorId);
  }

  Future<void> toggleFavorite(Layout layout) async {
    await _toggleFavorite(
      ToggleFavoriteParams(layoutId: layout.id, isFavorite: !layout.isFavorite),
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
        // Monitor padrão persistido: quando definido e ausente (desconectado),
        // nada é aplicado e o usuário é avisado.
        final preferredId =
            state.targetMonitorId ??
            _settingsCubit.state.settings.preferredMonitorId;
        final monitors = _monitorsCubit.state.monitors;
        if (preferredId != null &&
            !monitors.any((monitor) => monitor.id == preferredId)) {
          emit(
            state.copyWith(
              feedback:
                  'O monitor salvo como padrão não foi encontrado. '
                  'Escolha outro em "Aplicar em".',
            ),
          );
          return;
        }

        final monitor = _targetMonitor(windows, preferredId);
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
          emit(state.copyWith(feedback: 'Nenhuma janela para posicionar.'));
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
            // Registra o layout aplicado neste monitor (sem apagar o dos
            // demais) — o SnapRegionsService reage à mudança e atualiza as
            // zonas de encaixe no nativo.
            await _appliedLayoutsCubit.set(monitorKey(monitor), layout.id);
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

  Monitor? _targetMonitor(List<ManagedWindow> windows, int? preferredId) {
    final monitors = _monitorsCubit.state.monitors;
    if (monitors.isEmpty) return null;

    // Monitor padrão escolhido no seletor da galeria (persistido).
    if (preferredId != null) {
      for (final monitor in monitors) {
        if (monitor.id == preferredId) return monitor;
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
