import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../layouts/domain/repositories/layouts_repository.dart';
import '../../../rules/domain/repositories/rules_repository.dart';
import '../../../settings/domain/repositories/settings_repository.dart';
import '../../../workspaces/domain/repositories/workspaces_repository.dart';
import '../../data/backup_codec.dart';

/// Serializa layouts do usuário, workspaces, regras e preferências em JSON.
///
/// Presets não entram no backup — são semeados em qualquer instalação.
@injectable
class ExportBackup implements UseCase<String, NoParams> {
  const ExportBackup(
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
  Future<Either<Failure, String>> call(NoParams params) async {
    try {
      final allLayouts = (await _layoutsRepository.getLayouts()).getOrElse(
        (_) => [],
      );
      final workspaces = (await _workspacesRepository.getWorkspaces())
          .getOrElse((_) => []);
      final rules = (await _rulesRepository.getRules()).getOrElse((_) => []);
      final settings = (await _settingsRepository.getSettings()).fold(
        (_) => null,
        (value) => value,
      );

      final json = BackupCodec.encode(
        BackupData(
          layouts: allLayouts
              .where((layout) => !layout.isPreset)
              .toList(growable: false),
          workspaces: workspaces,
          rules: rules,
          settings: settings,
        ),
        layoutNames: {for (final layout in allLayouts) layout.id: layout.name},
      );
      return right(json);
    } catch (e) {
      return left(UnexpectedFailure('Falha ao exportar: $e'));
    }
  }
}
