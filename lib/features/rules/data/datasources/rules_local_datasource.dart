import 'package:injectable/injectable.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/services/database/app_database.dart';
import '../../domain/entities/rule.dart';
import '../models/rule_mapper.dart';

/// Persistência das regras no banco local.
abstract interface class RulesLocalDatasource {
  Future<List<Rule>> getRules();

  Future<Rule> saveRule(Rule rule);

  Future<void> deleteRule(int ruleId);
}

@LazySingleton(as: RulesLocalDatasource)
class RulesLocalDatasourceImpl implements RulesLocalDatasource {
  const RulesLocalDatasourceImpl(this._db);

  final AppDatabase _db;

  @override
  Future<List<Rule>> getRules() async {
    try {
      final rows = await _db.select(_db.rules).get();
      return rows.map(RuleMapper.fromRow).toList(growable: false);
    } catch (e) {
      throw DatabaseException('Falha ao carregar regras: $e');
    }
  }

  @override
  Future<Rule> saveRule(Rule rule) async {
    try {
      if (rule.id == 0) {
        final id = await _db
            .into(_db.rules)
            .insert(RuleMapper.toCompanion(rule));
        return rule.copyWith(id: id);
      }
      await (_db.update(_db.rules)..where((t) => t.id.equals(rule.id))).write(
        RuleMapper.toCompanion(rule),
      );
      return rule;
    } catch (e) {
      throw DatabaseException('Falha ao salvar regra: $e');
    }
  }

  @override
  Future<void> deleteRule(int ruleId) async {
    try {
      await (_db.delete(_db.rules)..where((t) => t.id.equals(ruleId))).go();
    } catch (e) {
      throw DatabaseException('Falha ao excluir regra: $e');
    }
  }
}
