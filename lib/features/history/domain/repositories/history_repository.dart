import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/history_entry.dart';

/// Contrato de persistência do histórico de atividades.
abstract interface class HistoryRepository {
  /// Entradas mais recentes primeiro.
  Future<Either<Failure, List<HistoryEntry>>> getEntries({int limit});

  Future<Either<Failure, Unit>> addEntry(HistoryEntry entry);

  Future<Either<Failure, Unit>> clear();
}
