import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';

/// Efeitos das preferências no sistema: login, Dock, barra de menus e
/// encaixe magnético.
abstract interface class SystemIntegrationRepository {
  Future<Either<Failure, Unit>> setLaunchAtLogin(bool enabled);

  Future<Either<Failure, Unit>> setDockVisible(bool visible);

  Future<Either<Failure, Unit>> setStatusBarVisible(bool visible);

  Future<Either<Failure, Unit>> setMagneticSnap(bool enabled);
}
