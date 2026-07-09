import 'package:equatable/equatable.dart';

import 'history_entry.dart';

/// Item de ranking de uso (título + contagem).
class UsageCount extends Equatable {
  const UsageCount(this.title, this.count);

  final String title;
  final int count;

  @override
  List<Object?> get props => [title, count];
}

/// Estatísticas derivadas do histórico de atividades.
class UsageStats extends Equatable {
  const UsageStats({
    this.totalActivities = 0,
    this.topLayouts = const [],
    this.topWorkspaces = const [],
  });

  final int totalActivities;
  final List<UsageCount> topLayouts;
  final List<UsageCount> topWorkspaces;

  bool get isEmpty => totalActivities == 0;

  /// Agrega o histórico em rankings de mais usados.
  factory UsageStats.fromEntries(List<HistoryEntry> entries, {int top = 3}) {
    final layoutCounts = <String, int>{};
    final workspaceCounts = <String, int>{};

    for (final entry in entries) {
      switch (entry.type) {
        case HistoryEntryType.layout:
          final match = RegExp("Aplicou '(.+)'").firstMatch(entry.title);
          if (match != null) {
            layoutCounts.update(
              match.group(1)!,
              (count) => count + 1,
              ifAbsent: () => 1,
            );
          }
        case HistoryEntryType.workspace:
          final match = RegExp(
            "Ativou o workspace '(.+)'",
          ).firstMatch(entry.title);
          if (match != null) {
            workspaceCounts.update(
              match.group(1)!,
              (count) => count + 1,
              ifAbsent: () => 1,
            );
          }
        case HistoryEntryType.rule:
          break;
      }
    }

    List<UsageCount> rank(Map<String, int> counts) {
      final ranked = [
        for (final entry in counts.entries) UsageCount(entry.key, entry.value),
      ]..sort((a, b) => b.count.compareTo(a.count));
      return ranked.take(top).toList(growable: false);
    }

    return UsageStats(
      totalActivities: entries.length,
      topLayouts: rank(layoutCounts),
      topWorkspaces: rank(workspaceCounts),
    );
  }

  @override
  List<Object?> get props => [totalActivities, topLayouts, topWorkspaces];
}
