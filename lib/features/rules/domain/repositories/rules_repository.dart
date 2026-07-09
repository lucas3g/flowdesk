import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/rule.dart';

/// Contrato de persistência das regras e do stream de apps abertos.
abstract interface class RulesRepository {
  Future<Either<Failure, List<Rule>>> getRules();

  Future<Either<Failure, Rule>> saveRule(Rule rule);

  Future<Either<Failure, Unit>> deleteRule(int ruleId);

  /// Emite (bundleId, appName) sempre que um app é aberto no macOS.
  Stream<({String bundleId, String appName})> appLaunches();
}
