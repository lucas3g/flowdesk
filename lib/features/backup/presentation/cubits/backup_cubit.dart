import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/usecases/usecase.dart';
import '../../../layouts/presentation/cubits/layouts_cubit.dart';
import '../../../rules/presentation/cubits/rules_cubit.dart';
import '../../../settings/presentation/cubits/settings_cubit.dart';
import '../../../workspaces/presentation/cubits/workspaces_cubit.dart';
import '../../domain/usecases/export_backup.dart';
import '../../domain/usecases/import_backup.dart';

/// Estado da tela de backup.
class BackupState extends Equatable {
  const BackupState({this.isBusy = false, this.feedback});

  final bool isBusy;
  final String? feedback;

  BackupState copyWith({bool? isBusy, String? feedback}) {
    return BackupState(isBusy: isBusy ?? this.isBusy, feedback: feedback);
  }

  @override
  List<Object?> get props => [isBusy, feedback];
}

/// Exporta/importa os dados do FlowDesk em JSON via dialogs do sistema.
@lazySingleton
class BackupCubit extends Cubit<BackupState> {
  BackupCubit(
    this._exportBackup,
    this._importBackup,
    this._layoutsCubit,
    this._workspacesCubit,
    this._rulesCubit,
    this._settingsCubit,
  ) : super(const BackupState());

  final ExportBackup _exportBackup;
  final ImportBackup _importBackup;
  final LayoutsCubit _layoutsCubit;
  final WorkspacesCubit _workspacesCubit;
  final RulesCubit _rulesCubit;
  final SettingsCubit _settingsCubit;

  static const XTypeGroup _jsonType = XTypeGroup(
    label: 'Backup do FlowDesk',
    extensions: ['json'],
  );

  Future<void> exportToFile() async {
    final location = await getSaveLocation(
      suggestedName: 'flowdesk-backup.json',
      acceptedTypeGroups: const [_jsonType],
    );
    if (location == null) return;

    emit(state.copyWith(isBusy: true));
    final result = await _exportBackup(const NoParams());
    await result.fold(
      (failure) async =>
          emit(BackupState(feedback: failure.message)),
      (json) async {
        await File(location.path).writeAsString(json);
        emit(BackupState(feedback: 'Backup exportado com sucesso.'));
      },
    );
  }

  Future<void> importFromFile() async {
    final file = await openFile(acceptedTypeGroups: const [_jsonType]);
    if (file == null) return;

    emit(state.copyWith(isBusy: true));
    final json = await File(file.path).readAsString();
    final result = await _importBackup(json);

    await result.fold(
      (failure) async => emit(BackupState(feedback: failure.message)),
      (summary) async {
        // Recarrega o app inteiro com os dados importados.
        await _layoutsCubit.load();
        await _workspacesCubit.load();
        await _rulesCubit.load();
        await _settingsCubit.load();
        emit(
          BackupState(
            feedback:
                'Importados ${summary.layouts} layouts, '
                '${summary.workspaces} workspaces e '
                '${summary.rules} regras.'
                '${summary.settingsApplied ? ' Preferências aplicadas.' : ''}',
          ),
        );
      },
    );
  }

  void clearFeedback() {
    if (state.feedback != null) emit(state.copyWith());
  }
}
