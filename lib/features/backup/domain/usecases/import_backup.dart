import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../layouts/domain/repositories/layouts_repository.dart';
import '../../../rules/domain/repositories/rules_repository.dart';
import '../../../settings/domain/repositories/settings_repository.dart';
import '../../../workspaces/domain/repositories/workspaces_repository.dart';
import '../../data/backup_codec.dart';

/// Resumo do que foi importado.
class ImportSummary extends Equatable {
  const ImportSummary({
    required this.layouts,
    required this.workspaces,
    required this.rules,
    required this.settingsApplied,
  });

  final int layouts;
  final int workspaces;
  final int rules;
  final bool settingsApplied;

  @override
  List<Object?> get props => [layouts, workspaces, rules, settingsApplied];
}

/// Importa um backup JSON: layouts e workspaces entram como novos registros
/// (vínculo workspace→layout resolvido por nome), regras são adicionadas e
/// as preferências substituídas.
@injectable
class ImportBackup implements UseCase<ImportSummary, String> {
  const ImportBackup(
    this._layoutsRepository,
    this._workspacesRepository,
    this._rulesRepository,
    this._settingsRepository,
  );

  final LayoutsRepository _layoutsRepository;
  final WorkspacesRepository _workspacesRepository;
  final RulesRepository _rulesRepository;
  final SettingsRepository _settingsRepository;

  @override
  Future<Either<Failure, ImportSummary>> call(String params) async {
    final ({BackupData data, Map<String, String?> workspaceLayoutNames})
    decoded;
    try {
      decoded = BackupCodec.decode(params);
    } on FormatException catch (e) {
      return left(ValidationFailure(e.message));
    } catch (e) {
      return left(const ValidationFailure('Arquivo de backup inválido.'));
    }

    var layoutsImported = 0;
    for (final layout in decoded.data.layouts) {
      final result = await _layoutsRepository.saveLayout(layout);
      if (result.isRight()) layoutsImported++;
    }

    // Resolve o vínculo por nome usando o estado pós-importação.
    final allLayouts = (await _layoutsRepository.getLayouts()).getOrElse(
      (_) => [],
    );
    int? layoutIdByName(String? name) {
      if (name == null) return null;
      for (final layout in allLayouts) {
        if (layout.name == name) return layout.id;
      }
      return null;
    }

    var workspacesImported = 0;
    for (final workspace in decoded.data.workspaces) {
      final result = await _workspacesRepository.saveWorkspace(
        workspace.copyWith(
          layoutId: () =>
              layoutIdByName(decoded.workspaceLayoutNames[workspace.name]),
        ),
      );
      if (result.isRight()) workspacesImported++;
    }

    var rulesImported = 0;
    for (final rule in decoded.data.rules) {
      final result = await _rulesRepository.saveRule(rule);
      if (result.isRight()) rulesImported++;
    }

    var settingsApplied = false;
    if (decoded.data.settings != null) {
      settingsApplied =
          (await _settingsRepository.saveSettings(
            decoded.data.settings!,
          )).isRight();
    }

    return right(
      ImportSummary(
        layouts: layoutsImported,
        workspaces: workspacesImported,
        rules: rulesImported,
        settingsApplied: settingsApplied,
      ),
    );
  }
}
