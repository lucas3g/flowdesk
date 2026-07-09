import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';

/// Contrato para abrir aplicativos do macOS por bundle id.
abstract interface class AppsLauncherRepository {
  /// Retorna false quando o app não está instalado.
  Future<Either<Failure, bool>> launchApp(String bundleId);
}
