import 'package:equatable/equatable.dart';

/// Tipo do evento registrado no histórico.
enum HistoryEntryType {
  layout,
  workspace,
  rule;

  static HistoryEntryType fromName(String name) =>
      HistoryEntryType.values.firstWhere(
        (t) => t.name == name,
        orElse: () => HistoryEntryType.layout,
      );
}

/// Evento do histórico de atividades.
class HistoryEntry extends Equatable {
  const HistoryEntry({
    this.id = 0,
    required this.type,
    required this.title,
    this.subtitle,
    required this.createdAt,
  });

  final int id;
  final HistoryEntryType type;
  final String title;
  final String? subtitle;
  final DateTime createdAt;

  @override
  List<Object?> get props => [id, type, title, subtitle, createdAt];
}
