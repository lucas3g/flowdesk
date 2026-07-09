import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/rule.dart';
import '../repositories/rules_repository.dart';

/// Insere ou atualiza uma regra.
@injectable
class SaveRule implements UseCase<Rule, Rule> {
  const SaveRule(this._repository);

  final RulesRepository _repository;

  @override
  Future<Either<Failure, Rule>> call(Rule params) {
    if (params.bundleId.trim().isEmpty) {
      return Future.value(
        left(const ValidationFailure('A regra precisa de um aplicativo.')),
      );
    }
    final needsTarget =
        params.actionType == RuleActionType.moveToMonitor ||
        params.actionType == RuleActionType.applyRegion;
    if (needsTarget && params.targetValue.trim().isEmpty) {
      return Future.value(
        left(const ValidationFailure('A regra precisa de um alvo.')),
      );
    }
    return _repository.saveRule(params);
  }
}
