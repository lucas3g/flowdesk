import 'package:equatable/equatable.dart';

/// Ação executada quando o app da regra é aberto.
enum RuleActionType {
  moveToMonitor('Mover para o monitor'),
  applyRegion('Encaixar na região'),
  maximize('Maximizar'),
  center('Centralizar');

  const RuleActionType(this.label);

  final String label;

  static RuleActionType fromName(String name) => RuleActionType.values
      .firstWhere((t) => t.name == name, orElse: () => RuleActionType.center);
}

/// Regra "se abrir X, fazer Y".
class Rule extends Equatable {
  const Rule({
    this.id = 0,
    required this.bundleId,
    required this.appName,
    required this.actionType,
    this.targetValue = '',
    this.isActive = true,
  });

  final int id;
  final String bundleId;
  final String appName;
  final RuleActionType actionType;

  /// Alvo da ação:
  /// - [RuleActionType.moveToMonitor]: nome do monitor;
  /// - [RuleActionType.applyRegion]: `layoutId:índiceDaRegião`;
  /// - demais: vazio.
  final String targetValue;
  final bool isActive;

  /// Para [RuleActionType.applyRegion]: (layoutId, índice) ou null.
  (int, int)? get regionTarget {
    final parts = targetValue.split(':');
    if (parts.length != 2) return null;
    final layoutId = int.tryParse(parts[0]);
    final regionIndex = int.tryParse(parts[1]);
    if (layoutId == null || regionIndex == null) return null;
    return (layoutId, regionIndex);
  }

  Rule copyWith({
    int? id,
    String? bundleId,
    String? appName,
    RuleActionType? actionType,
    String? targetValue,
    bool? isActive,
  }) {
    return Rule(
      id: id ?? this.id,
      bundleId: bundleId ?? this.bundleId,
      appName: appName ?? this.appName,
      actionType: actionType ?? this.actionType,
      targetValue: targetValue ?? this.targetValue,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [
    id,
    bundleId,
    appName,
    actionType,
    targetValue,
    isActive,
  ];
}
