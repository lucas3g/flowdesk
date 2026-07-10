import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/app_settings.dart';

/// Efeitos das preferências no sistema: login, Dock, barra de menus e
/// encaixe magnético.
abstract interface class SystemIntegrationRepository {
  Future<Either<Failure, Unit>> setLaunchAtLogin(bool enabled);

  Future<Either<Failure, Unit>> setDockVisible(bool visible);

  Future<Either<Failure, Unit>> setStatusBarVisible(bool visible);

  Future<Either<Failure, Unit>> setMagneticSnap(bool enabled);

  /// Envia as zonas de encaixe do layout ao nativo (coordenadas CG
  /// absolutas, já com gap/margem). Lista vazia com [enabled] falso
  /// desativa o modo.
  Future<Either<Failure, Unit>> setLayoutSnapRegions({
    required bool enabled,
    required List<({double x, double y, double width, double height})> regions,
  });

  /// Apps (ou instâncias específicas, por título de janela) que não
  /// participam do encaixe ao arrastar.
  Future<Either<Failure, Unit>> setSnapExcludedApps(
    List<SnapExcludedApp> apps,
  );
}
