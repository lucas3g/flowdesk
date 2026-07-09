import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/rules_repository.dart';

/// Exclui uma regra.
@injectable
class DeleteRule implements UseCase<Unit, int> {
  const DeleteRule(this._repository);

  final RulesRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(int params) {
    return _repository.deleteRule(params);
  }
}
