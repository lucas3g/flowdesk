import 'dart:async';

import 'package:drift/native.dart';
import 'package:flowdesk/core/platform/platform_channel.dart';
import 'package:flowdesk/core/services/database/app_database.dart';
import 'package:flowdesk/features/rules/data/datasources/rules_local_datasource.dart';
import 'package:flowdesk/features/rules/data/repositories/rules_repository_impl.dart';
import 'package:flowdesk/features/rules/domain/entities/rule.dart';
import 'package:flowdesk/features/rules/domain/repositories/rules_repository.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fakes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late StreamController<Object?> events;
  late RulesRepositoryImpl repository;
  late List<MethodCall> channelCalls;

  const workspaceChannel = MethodChannel('test/workspace');

  setUp(() {
    db = AppDatabase.withExecutor(NativeDatabase.memory());
    events = StreamController<Object?>.broadcast();
    channelCalls = [];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(workspaceChannel, (call) async {
          channelCalls.add(call);
          return null;
        });
    repository = RulesRepositoryImpl(
      RulesLocalDatasourceImpl(db),
      FakeEventChannel(events.stream),
      PlatformChannel.withChannel(workspaceChannel),
    );
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(workspaceChannel, null);
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
    final received = <AppLaunchEvent>[];
    final subscription = repository.appLaunches().listen(received.add);

    events
      ..add({'bundleId': 'com.slack', 'appName': 'Slack'})
      ..add('lixo')
      ..add({'appName': 'Sem bundle'})
      ..add({
        'bundleId': 'com.figma',
        'appName': 'Figma',
        'windowId': 42,
        'pid': 500,
      })
      ..add({'bundleId': 'com.zed', 'appName': 'Zed', 'windowId': 'abc'});
    await Future<void>.delayed(Duration.zero);
    await subscription.cancel();

    expect(received.length, 3);
    expect(received[0].bundleId, 'com.slack');
    expect(received[0].windowId, isNull);
    expect(received[0].pid, isNull);
    expect(received[1].appName, 'Figma');
    expect(received[1].windowId, 42);
    expect(received[1].pid, 500);
    // windowId com tipo inválido é tratado como ausente.
    expect(received[2].windowId, isNull);
  });

  test('setRuleApps envia os bundleIds ao canal nativo', () async {
    await repository.setRuleApps(const ['com.slack', 'com.figma']);

    expect(channelCalls, hasLength(1));
    expect(channelCalls.single.method, 'setRuleApps');
    expect(channelCalls.single.arguments, {
      'bundleIds': ['com.slack', 'com.figma'],
    });
  });

  test('setRuleApps ignora canal sem suporte', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(workspaceChannel, null);

    await expectLater(repository.setRuleApps(const ['com.slack']), completes);
  });
}
