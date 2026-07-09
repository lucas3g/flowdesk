import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';

/// Efeitos das preferências no sistema: login, Dock e barra de menus.
abstract interface class SystemIntegrationRepository {
  Future<Either<Failure, Unit>> setLaunchAtLogin(bool enabled);

  Future<Either<Failure, Unit>> setDockVisible(bool visible);

  Future<Either<Failure, Unit>> setStatusBarVisible(bool visible);
}
