import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/usecases/usecase.dart';
import '../../../history/domain/entities/history_entry.dart';
import '../../../history/domain/usecases/history_usecases.dart';
import '../../../monitors/domain/entities/monitor.dart';
import '../../../monitors/presentation/cubits/monitors_cubit.dart';
import '../../../settings/presentation/cubits/settings_cubit.dart';
import '../../domain/entities/workspace.dart';
import '../../domain/usecases/apply_workspace.dart';
import '../../domain/usecases/delete_workspace.dart';
import '../../domain/usecases/get_workspaces.dart';
import '../../domain/usecases/save_workspace.dart';
import 'workspaces_state.dart';

/// Tela de workspaces: CRUD e aplicação em um clique.
@lazySingleton
class WorkspacesCubit extends Cubit<WorkspacesState> {
  WorkspacesCubit(
    this._getWorkspaces,
    this._saveWorkspace,
    this._deleteWorkspace,
    this._applyWorkspace,
    this._monitorsCubit,
    this._settingsCubit,
    this._addHistoryEntry,
  ) : super(const WorkspacesState());

  final GetWorkspaces _getWorkspaces;
  final SaveWorkspace _saveWorkspace;
  final DeleteWorkspace _deleteWorkspace;
  final ApplyWorkspace _applyWorkspace;
  final MonitorsCubit _monitorsCubit;
  final SettingsCubit _settingsCubit;
  final AddHistoryEntry _addHistoryEntry;

  Future<void> load() async {
    final result = await _getWorkspaces(const NoParams());
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: WorkspacesStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (workspaces) => emit(
        state.copyWith(status: WorkspacesStatus.ready, workspaces: workspaces),
      ),
    );
  }

  Future<void> save(Workspace workspace) async {
    final result = await _saveWorkspace(workspace);
    await result.fold(
      (failure) async => emit(state.copyWith(feedback: failure.message)),
      (_) async {
        await load();
        emit(state.copyWith(feedback: "Workspace '${workspace.name}' salvo."));
      },
    );
  }

  Future<void> delete(Workspace workspace) async {
    await _deleteWorkspace(workspace.id);
    await load();
  }

  /// Abre os apps, aguarda as janelas e aplica o layout do workspace.
  Future<void> apply(Workspace workspace) async {
    // Recarrega a geometria dos monitores: a área útil muda sem aviso
    // confiável quando a Dock/menu bar migram de tela.
    await _monitorsCubit.refresh();
    final monitor = _primaryMonitor();
    if (monitor == null) {
      emit(state.copyWith(feedback: 'Nenhum monitor detectado.'));
      return;
    }

    emit(state.copyWith(applyingId: () => workspace.id));

    final settings = _settingsCubit.state.settings;
    final result = await _applyWorkspace(
      ApplyWorkspaceParams(
        workspace: workspace,
        monitor: monitor,
        gap: settings.windowGap,
        margin: settings.screenMargin,
      ),
    );

    await result.fold(
      (failure) async => emit(
        state.copyWith(applyingId: () => null, feedback: failure.message),
      ),
      (applied) async {
        await _addHistoryEntry(
          AddHistoryParams(
            type: HistoryEntryType.workspace,
            title: "Ativou o workspace '${workspace.name}'",
            subtitle:
                '${applied.positioned} '
                '${applied.positioned == 1 ? 'janela posicionada' : 'janelas posicionadas'}',
          ),
        );
        await load();
        final missing = applied.missingApps.isEmpty
            ? ''
            : ' Não abriram: ${applied.missingApps.join(', ')}.';
        emit(
          state.copyWith(
            applyingId: () => null,
            feedback:
                "Workspace '${workspace.name}' aplicado "
                '(${applied.positioned} '
                '${applied.positioned == 1 ? 'janela' : 'janelas'}).$missing',
          ),
        );
      },
    );
  }

  void clearFeedback() {
    if (state.feedback != null) emit(state.copyWith());
  }

  Monitor? _primaryMonitor() {
    final monitors = _monitorsCubit.state.monitors;
    if (monitors.isEmpty) return null;
    return monitors.firstWhere(
      (monitor) => monitor.isPrimary,
      orElse: () => monitors.first,
    );
  }
}
