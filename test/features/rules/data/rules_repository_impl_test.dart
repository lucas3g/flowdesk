import 'dart:async';

import 'package:drift/native.dart';
import 'package:flowdesk/core/services/database/app_database.dart';
import 'package:flowdesk/features/rules/data/datasources/rules_local_datasource.dart';
import 'package:flowdesk/features/rules/data/repositories/rules_repository_impl.dart';
import 'package:flowdesk/features/rules/domain/entities/rule.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fakes.dart';

void main() {
  late AppDatabase db;
  late StreamController<Object?> events;
  late RulesRepositoryImpl repository;

  setUp(() {
    db = AppDatabase.withExecutor(NativeDatabase.memory());
    events = StreamController<Object?>.broadcast();
    repository = RulesRepositoryImpl(
      RulesLocalDatasourceImpl(db),
      FakeEventChannel(events.stream),
    );
  });

  tearDown(() async {
    await events.close();
    await db.close();
  });

  test('salva, alterna e exclui regras', () async {
    const rule = Rule(
      bundleId: 'com.slack',
      appName: 'Slack',
      actionType: RuleActionType.moveToMonitor,
      targetValue: 'Dell 4K',
    );

    final saved = (await repository.saveRule(
      rule,
    )).getOrElse((f) => fail(f.message));
    expect(saved.id, greaterThan(0));

    final paused = (await repository.saveRule(
      saved.copyWith(isActive: false),
    )).getOrElse((f) => fail(f.message));
    expect(paused.isActive, isFalse);

    final loaded = (await repository.getRules()).getOrElse(
      (f) => fail(f.message),
    );
    expect(loaded.single.actionType, RuleActionType.moveToMonitor);
    expect(loaded.single.isActive, isFalse);

    await repository.deleteRule(saved.id);
    final after = (await repository.getRules()).getOrElse(
      (f) => fail(f.message),
    );
    expect(after, isEmpty);
  });

  test('regionTarget interpreta o targetValue', () {
    const rule = Rule(
      bundleId: 'x',
      appName: 'X',
      actionType: RuleActionType.applyRegion,
      targetValue: '12:2',
    );
    expect(rule.regionTarget, (12, 2));

    const invalid = Rule(
      bundleId: 'x',
      appName: 'X',
      actionType: RuleActionType.applyRegion,
      targetValue: 'abc',
    );
    expect(invalid.regionTarget, isNull);
  });

  test('appLaunches converte eventos do canal e filtra inválidos', () async {
    final received = <({String bundleId, String appName})>[];
    final subscription = repository.appLaunches().listen(received.add);

    events
      ..add({'bundleId': 'com.slack', 'appName': 'Slack'})
      ..add('lixo')
      ..add({'appName': 'Sem bundle'})
      ..add({'bundleId': 'com.figma', 'appName': 'Figma'});
    await Future<void>.delayed(Duration.zero);
    await subscription.cancel();

    expect(received.length, 2);
    expect(received.first.bundleId, 'com.slack');
    expect(received.last.appName, 'Figma');
  });
}
