import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/app_settings.dart';
import '../repositories/system_integration_repository.dart';

/// Aplica no macOS os efeitos das preferências (login, Dock, menu bar,
/// encaixe magnético).
///
/// Falhas individuais não interrompem as demais aplicações.
@injectable
class ApplySystemIntegration implements UseCase<Unit, AppSettings> {
  const ApplySystemIntegration(this._repository);

  final SystemIntegrationRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(AppSettings params) async {
    await _repository.setLaunchAtLogin(params.launchAtLogin);
    await _repository.setDockVisible(params.showInDock);
    await _repository.setStatusBarVisible(params.showMenuBarIcon);
    await _repository.setMagneticSnap(params.magneticSnap);
    return right(unit);
  }
}
