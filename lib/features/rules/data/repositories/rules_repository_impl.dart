import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/platform/platform_event_channel.dart';
import '../../domain/entities/rule.dart';
import '../../domain/repositories/rules_repository.dart';
import '../datasources/rules_local_datasource.dart';

@LazySingleton(as: RulesRepository)
class RulesRepositoryImpl implements RulesRepository {
  const RulesRepositoryImpl(
    this._datasource,
    @Named('workspaceEventsChannel') this._appLaunchesChannel,
  );

  final RulesLocalDatasource _datasource;
  final PlatformEventChannel _appLaunchesChannel;

  @override
  Future<Either<Failure, List<Rule>>> getRules() async {
    try {
      return right(await _datasource.getRules());
    } on DatabaseException catch (e) {
      return left(DatabaseFailure(e.message));
    } catch (e) {
      return left(UnexpectedFailure('$e'));
    }
  }

  @override
  Future<Either<Failure, Rule>> saveRule(Rule rule) async {
    try {
      return right(await _datasource.saveRule(rule));
    } on DatabaseException catch (e) {
      return left(DatabaseFailure(e.message));
    } catch (e) {
      return left(UnexpectedFailure('$e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteRule(int ruleId) async {
    try {
      await _datasource.deleteRule(ruleId);
      return right(unit);
    } on DatabaseException catch (e) {
      return left(DatabaseFailure(e.message));
    } catch (e) {
      return left(UnexpectedFailure('$e'));
    }
  }

  @override
  Stream<({String bundleId, String appName})> appLaunches() {
    return _appLaunchesChannel
        .receive<Object?>()
        .where((event) => event is Map)
        .map((event) {
          final map = event as Map;
          return (
            bundleId: '${map['bundleId'] ?? ''}',
            appName: '${map['appName'] ?? ''}',
          );
        })
        .where((event) => event.bundleId.isNotEmpty);
  }
}
