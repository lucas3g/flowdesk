import 'package:drift/native.dart';
import 'package:flowdesk/core/services/database/app_database.dart';
import 'package:flowdesk/features/history/data/datasources/history_local_datasource.dart';
import 'package:flowdesk/features/history/data/repositories/history_repository_impl.dart';
import 'package:flowdesk/features/history/domain/entities/history_entry.dart';
import 'package:flowdesk/features/history/domain/entities/usage_stats.dart';
import 'package:flowdesk/features/history/presentation/pages/history_page.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HistoryRepository', () {
    late AppDatabase db;
    late HistoryRepositoryImpl repository;

    setUp(() {
      db = AppDatabase.withExecutor(NativeDatabase.memory());
      repository = HistoryRepositoryImpl(HistoryLocalDatasourceImpl(db));
    });

    tearDown(() async => db.close());

    test('registra e lista com as mais recentes primeiro', () async {
      await repository.addEntry(
        HistoryEntry(
          type: HistoryEntryType.layout,
          title: 'Primeiro',
          createdAt: DateTime(2026, 7, 8, 10),
        ),
      );
      await repository.addEntry(
        HistoryEntry(
          type: HistoryEntryType.workspace,
          title: 'Segundo',
          subtitle: '3 janelas',
          createdAt: DateTime(2026, 7, 8, 12),
        ),
      );

      final entries = (await repository.getEntries()).getOrElse(
        (f) => fail(f.message),
      );
      expect(entries.length, 2);
      expect(entries.first.title, 'Segundo');
      expect(entries.first.type, HistoryEntryType.workspace);
      expect(entries.first.subtitle, '3 janelas');
    });

    test('clear remove tudo', () async {
      await repository.addEntry(
        HistoryEntry(
          type: HistoryEntryType.rule,
          title: 'Regra',
          createdAt: DateTime(2026, 7, 8),
        ),
      );

      await repository.clear();

      final entries = (await repository.getEntries()).getOrElse(
        (f) => fail(f.message),
      );
      expect(entries, isEmpty);
    });
  });

  group('UsageStats', () {
    HistoryEntry entry(HistoryEntryType type, String title) =>
        HistoryEntry(type: type, title: title, createdAt: DateTime(2026, 7, 8));

    test('ranqueia layouts e workspaces mais usados', () {
      final stats = UsageStats.fromEntries([
        entry(HistoryEntryType.layout, "Aplicou 'Código & Terminal'"),
        entry(HistoryEntryType.layout, "Aplicou 'Código & Terminal'"),
        entry(HistoryEntryType.layout, "Aplicou 'Foco Central'"),
        entry(HistoryEntryType.workspace, "Ativou o workspace 'Dev'"),
        entry(HistoryEntryType.rule, 'Regra aplicada a Slack'),
      ]);

      expect(stats.totalActivities, 5);
      expect(stats.topLayouts.first, const UsageCount('Código & Terminal', 2));
      expect(stats.topLayouts.last, const UsageCount('Foco Central', 1));
      expect(stats.topWorkspaces.single, const UsageCount('Dev', 1));
    });

    test('histórico vazio produz stats vazias', () {
      final stats = UsageStats.fromEntries(const []);
      expect(stats.isEmpty, isTrue);
      expect(stats.topLayouts, isEmpty);
    });
  });

  group('relativeTime', () {
    final now = DateTime(2026, 7, 8, 12, 0);

    test('formata intervalos relativos em pt-BR', () {
      expect(
        relativeTime(now.subtract(const Duration(seconds: 30)), now: now),
        'agora mesmo',
      );
      expect(
        relativeTime(now.subtract(const Duration(minutes: 12)), now: now),
        'há 12 minutos',
      );
      expect(
        relativeTime(now.subtract(const Duration(hours: 1)), now: now),
        'há 1 hora',
      );
      expect(
        relativeTime(now.subtract(const Duration(days: 2)), now: now),
        'há 2 dias',
      );
    });
  });
}
