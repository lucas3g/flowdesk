import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/rule.dart';
import '../repositories/rules_repository.dart';

/// Lista todas as regras.
@injectable
class GetRules implements UseCase<List<Rule>, NoParams> {
  const GetRules(this._repository);

  final RulesRepository _repository;

  @override
  Future<Either<Failure, List<Rule>>> call(NoParams params) {
    return _repository.getRules();
  }
}
