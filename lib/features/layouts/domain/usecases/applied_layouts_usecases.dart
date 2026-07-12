import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/layouts_repository.dart';

/// Lista o layout aplicado em cada monitor (chave estável → id do layout).
@injectable
class GetAppliedLayouts implements UseCase<Map<String, int>, NoParams> {
  const GetAppliedLayouts(this._repository);

  final LayoutsRepository _repository;

  @override
  Future<Either<Failure, Map<String, int>>> call(NoParams params) {
    return _repository.getAppliedLayouts();
  }
}

class SetAppliedLayoutParams extends Equatable {
  const SetAppliedLayoutParams({
    required this.monitorKey,
    required this.layoutId,
  });

  final String monitorKey;
  final int layoutId;

  @override
  List<Object?> get props => [monitorKey, layoutId];
}

/// Registra (ou substitui) o layout aplicado em um monitor.
@injectable
class SetAppliedLayout implements UseCase<Unit, SetAppliedLayoutParams> {
  const SetAppliedLayout(this._repository);

  final LayoutsRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(SetAppliedLayoutParams params) {
    return _repository.setAppliedLayout(params.monitorKey, params.layoutId);
  }
}

/// Remove o layout aplicado de um monitor.
@injectable
class RemoveAppliedLayout implements UseCase<Unit, String> {
  const RemoveAppliedLayout(this._repository);

  final LayoutsRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(String monitorKey) {
    return _repository.removeAppliedLayout(monitorKey);
  }
}
