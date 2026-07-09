import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/license.dart';

/// Ciclo de vida da licença premium: ativação com a chave comprada no
/// Paddle, leitura do cache local e revalidação com a API de licenças.
abstract interface class LicenseRepository {
  /// Licença em cache, com o plano efetivo já calculado (expiração +
  /// tolerância offline). Nunca falha por ausência de rede.
  Future<Either<Failure, License>> getLicense();

  /// Ativa a chave nesta instalação e persiste o entitlement recebido.
  Future<Either<Failure, License>> activate(String key);

  /// Revalida a licença com o servidor e atualiza o cache.
  Future<Either<Failure, License>> refresh();

  /// Libera o seat desta instalação e limpa o cache local.
  Future<Either<Failure, License>> deactivate();
}
