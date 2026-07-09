import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../errors/failures.dart';

/// Contrato base para use cases assíncronos.
abstract interface class UseCase<T, Params> {
  Future<Either<Failure, T>> call(Params params);
}

/// Contrato base para use cases que expõem streams (ex.: mudanças de monitores).
abstract interface class StreamUseCase<T, Params> {
  Stream<Either<Failure, T>> call(Params params);
}

/// Parâmetro vazio para use cases sem entrada.
class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object?> get props => const [];
}
