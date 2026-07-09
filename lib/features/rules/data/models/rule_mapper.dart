import 'package:drift/drift.dart';

import '../../../../core/services/database/app_database.dart';
import '../../domain/entities/rule.dart';

/// Conversões entre linhas do banco e a entidade de regra.
abstract final class RuleMapper {
  static Rule fromRow(RuleRow row) {
    return Rule(
      id: row.id,
      bundleId: row.bundleId,
      appName: row.appName,
      actionType: RuleActionType.fromName(row.actionType),
      targetValue: row.targetValue,
      isActive: row.isActive,
    );
  }

  static RulesCompanion toCompanion(Rule rule) {
    return RulesCompanion(
      id: rule.id == 0 ? const Value.absent() : Value(rule.id),
      bundleId: Value(rule.bundleId),
      appName: Value(rule.appName),
      actionType: Value(rule.actionType.name),
      targetValue: Value(rule.targetValue),
      isActive: Value(rule.isActive),
    );
  }
}
