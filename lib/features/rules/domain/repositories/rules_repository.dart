import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/rule.dart';

/// Evento de abertura emitido pela plataforma. `windowId == null` indica o
/// lançamento do processo (comportamento legado); `windowId != null` indica
/// uma janela específica recém-criada de um app já em execução.
typedef AppLaunchEvent = ({
  String bundleId,
  String appName,
  int? windowId,
  int? pid,
});

/// Contrato de persistência das regras e do stream de apps abertos.
abstract interface class RulesRepository {
  Future<Either<Failure, List<Rule>>> getRules();

  Future<Either<Failure, Rule>> saveRule(Rule rule);

  Future<Either<Failure, Unit>> deleteRule(int ruleId);

  /// Emite um evento sempre que um app é aberto ou cria uma nova janela.
  Stream<AppLaunchEvent> appLaunches();

  /// Sincroniza com o nativo os bundleIds com regra ativa, para que novas
  /// janelas desses apps sejam observadas mesmo com o app já em execução.
  Future<void> setRuleApps(List<String> bundleIds);
}
