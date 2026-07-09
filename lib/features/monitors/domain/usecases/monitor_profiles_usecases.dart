import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/monitor_profile.dart';
import '../repositories/monitor_profiles_repository.dart';

/// Lista os perfis de monitores salvos.
@injectable
class GetMonitorProfiles implements UseCase<List<MonitorProfile>, NoParams> {
  const GetMonitorProfiles(this._repository);

  final MonitorProfilesRepository _repository;

  @override
  Future<Either<Failure, List<MonitorProfile>>> call(NoParams params) {
    return _repository.getProfiles();
  }
}

/// Salva o perfil de uma configuração de monitores.
@injectable
class SaveMonitorProfile implements UseCase<MonitorProfile, MonitorProfile> {
  const SaveMonitorProfile(this._repository);

  final MonitorProfilesRepository _repository;

  @override
  Future<Either<Failure, MonitorProfile>> call(MonitorProfile params) {
    if (params.name.trim().isEmpty) {
      return Future.value(
        left(const ValidationFailure('O perfil precisa de um nome.')),
      );
    }
    if (params.workspaceId == null && params.layoutId == null) {
      return Future.value(
        left(
          const ValidationFailure(
            'O perfil precisa de um workspace ou layout.',
          ),
        ),
      );
    }
    return _repository.saveProfile(params);
  }
}

/// Exclui um perfil de monitores.
@injectable
class DeleteMonitorProfile implements UseCase<Unit, int> {
  const DeleteMonitorProfile(this._repository);

  final MonitorProfilesRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(int params) {
    return _repository.deleteProfile(params);
  }
}
