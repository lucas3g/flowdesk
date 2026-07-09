import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';

/// Última posição conhecida da janela principal de um app, por
/// configuração de monitores (Auto Restore).
typedef StoredWindowPosition = ({
  double x,
  double y,
  double width,
  double height,
});

/// Contrato de persistência das posições de janelas.
abstract interface class WindowPositionsRepository {
  Future<Either<Failure, Unit>> savePosition({
    required String bundleId,
    required String monitorFingerprint,
    required double x,
    required double y,
    required double width,
    required double height,
  });

  Future<Either<Failure, StoredWindowPosition?>> getPosition({
    required String bundleId,
    required String monitorFingerprint,
  });
}
