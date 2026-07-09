import 'package:equatable/equatable.dart';

import '../../domain/entities/rule.dart';

enum RulesStatus { loading, ready, error }

/// Estado da tela de regras.
class RulesState extends Equatable {
  const RulesState({
    this.status = RulesStatus.loading,
    this.rules = const [],
    this.errorMessage,
    this.feedback,
  });

  final RulesStatus status;
  final List<Rule> rules;
  final String? errorMessage;
  final String? feedback;

  RulesState copyWith({
    RulesStatus? status,
    List<Rule>? rules,
    String? errorMessage,
    String? feedback,
  }) {
    return RulesState(
      status: status ?? this.status,
      rules: rules ?? this.rules,
      errorMessage: errorMessage,
      feedback: feedback,
    );
  }

  @override
  List<Object?> get props => [status, rules, errorMessage, feedback];
}
