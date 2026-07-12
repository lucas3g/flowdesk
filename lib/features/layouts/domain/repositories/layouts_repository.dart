import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/layout.dart';

/// Contrato de persistência de layouts.
abstract interface class LayoutsRepository {
  /// Lista todos os layouts (semeia os presets na primeira execução).
  Future<Either<Failure, List<Layout>>> getLayouts();

  /// Insere (id 0) ou atualiza um layout com suas regiões.
  Future<Either<Failure, Layout>> saveLayout(Layout layout);

  Future<Either<Failure, Unit>> deleteLayout(int layoutId);

  Future<Either<Failure, Unit>> setFavorite(int layoutId, bool isFavorite);

  /// Layout aplicado em cada monitor (chave estável → id do layout).
  Future<Either<Failure, Map<String, int>>> getAppliedLayouts();

  Future<Either<Failure, Unit>> setAppliedLayout(
    String monitorKey,
    int layoutId,
  );

  Future<Either<Failure, Unit>> removeAppliedLayout(String monitorKey);
}
