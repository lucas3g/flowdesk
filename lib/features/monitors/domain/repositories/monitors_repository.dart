import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/monitor.dart';

/// Contrato de acesso aos monitores conectados.
abstract interface class MonitorsRepository {
  Future<Either<Failure, List<Monitor>>> getMonitors();

  /// Emite a lista completa a cada mudança de configuração de telas
  /// (conexão, remoção, reorganização), começando pelo estado atual.
  Stream<Either<Failure, List<Monitor>>> watchMonitors();
}
