import 'package:flowdesk/core/usecases/usecase.dart';
import 'package:flowdesk/features/monitors/domain/entities/monitor.dart';
import 'package:flowdesk/features/monitors/presentation/cubits/monitors_cubit.dart';
import 'package:flowdesk/features/monitors/presentation/cubits/monitors_state.dart';
import 'package:flowdesk/features/rules/domain/entities/rule.dart';
import 'package:flowdesk/features/rules/domain/repositories/rules_repository.dart';
import 'package:flowdesk/features/rules/domain/usecases/apply_rule_to_window.dart';
import 'package:flowdesk/features/rules/domain/usecases/delete_rule.dart';
import 'package:flowdesk/features/rules/domain/usecases/get_rules.dart';
import 'package:flowdesk/features/rules/domain/usecases/save_rule.dart';
import 'package:flowdesk/features/rules/presentation/cubits/rules_cubit.dart';
import 'package:flowdesk/features/rules/presentation/cubits/rules_state.dart';
import 'package:flowdesk/features/settings/domain/usecases/get_settings.dart';
import 'package:flowdesk/features/settings/domain/usecases/save_settings.dart';
import 'package:flowdesk/features/settings/presentation/cubits/settings_cubit.dart';
import 'package:flowdesk/features/windows/domain/entities/managed_window.dart';
import 'package:flowdesk/features/windows/domain/usecases/get_windows.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fakes.dart';

class _MockGetRules extends Mock implements GetRules {}

class _MockSaveRule extends Mock implements SaveRule {}

class _MockDeleteRule extends Mock implements DeleteRule {}

class _MockApplyRule extends Mock implements ApplyRuleToWindow {}

class _MockRulesRepository extends Mock implements RulesRepository {}

class _MockGetWindows extends Mock implements GetWindows {}

class _MockGetSettings extends Mock implements GetSettings {}

class _MockSaveSettings extends Mock implements SaveSettings {}

class _MockMonitorsCubit extends MockCubit<MonitorsState>
    implements MonitorsCubit {}

const _monitor = Monitor(
  id: 1,
  name: 'MacBook',
  x: 0,
  y: 0,
  width: 1000,
  height: 800,
  visibleWidth: 1000,
  visibleHeight: 800,
  pixelWidth: 2000,
  pixelHeight: 1600,
  scale: 2,
  refreshRate: 60,
  isPrimary: true,
  isBuiltIn: true,
);

const _slackRule = Rule(
  id: 1,
  bundleId: 'com.slack',
  appName: 'Slack',
  actionType: RuleActionType.center,
);

const _window = ManagedWindow(
  id: 7,
  pid: 70,
  appName: 'Slack',
  bundleId: 'com.slack',
  title: '',
  x: 0,
  y: 0,
  width: 900,
  height: 700,
  monitorId: 1,
  isFocused: true,
);

void main() {
  late _MockGetRules getRules;
  late _MockSaveRule saveRule;
  late _MockDeleteRule deleteRule;
  late _MockApplyRule applyRule;
  late _MockRulesRepository repository;
  late _MockGetWindows getWindows;
  late _MockMonitorsCubit monitorsCubit;
  late SettingsCubit settingsCubit;

  setUpAll(() {
    registerFallbackValue(const NoParams());
    registerFallbackValue(_slackRule);
    registerFallbackValue(
      const ApplyRuleParams(rule: _slackRule, window: _window, monitors: []),
    );
  });

  setUp(() {
    getRules = _MockGetRules();
    saveRule = _MockSaveRule();
    deleteRule = _MockDeleteRule();
    applyRule = _MockApplyRule();
    repository = _MockRulesRepository();
    getWindows = _MockGetWindows();
    monitorsCubit = _MockMonitorsCubit();
    settingsCubit = SettingsCubit(
      _MockGetSettings(),
      _MockSaveSettings(),
      FakeApplySystemIntegration(),
    );

    when(() => getRules(any())).thenAnswer((_) async => right([_slackRule]));
    when(() => getWindows(any())).thenAnswer((_) async => right([_window]));
    when(() => applyRule(any())).thenAnswer((_) async => right(true));
    when(() => monitorsCubit.state).thenReturn(
      const MonitorsState(status: MonitorsStatus.ready, monitors: [_monitor]),
    );
    when(() => monitorsCubit.refresh()).thenAnswer((_) async {});
  });

  tearDown(() => settingsCubit.close());

  RulesCubit buildCubit() => RulesCubit(
    getRules,
    saveRule,
    deleteRule,
    applyRule,
    repository,
    getWindows,
    monitorsCubit,
    settingsCubit,
    FakeAddHistoryEntry(),
  );

  blocTest<RulesCubit, RulesState>(
    'load carrega as regras',
    build: buildCubit,
    act: (cubit) => cubit.load(),
    expect: () => [
      isA<RulesState>()
          .having((s) => s.status, 'status', RulesStatus.ready)
          .having((s) => s.rules.length, 'rules', 1),
    ],
  );

  blocTest<RulesCubit, RulesState>(
    'engine aplica a regra quando o app com regra ativa abre',
    build: buildCubit,
    seed: () => const RulesState(
      status: RulesStatus.ready,
      rules: [_slackRule],
    ),
    act: (cubit) =>
        cubit.onAppLaunched((bundleId: 'com.slack', appName: 'Slack')),
    verify: (_) {
      final captured =
          verify(() => applyRule(captureAny())).captured.single
              as ApplyRuleParams;
      expect(captured.rule, _slackRule);
      expect(captured.window, _window);
      expect(captured.monitors.single, _monitor);
      expect(captured.gap, 8);
      expect(captured.margin, 8);
    },
  );

  blocTest<RulesCubit, RulesState>(
    'engine ignora apps sem regra e regras pausadas',
    build: buildCubit,
    seed: () => RulesState(
      status: RulesStatus.ready,
      rules: [_slackRule.copyWith(isActive: false)],
    ),
    act: (cubit) async {
      await cubit.onAppLaunched((bundleId: 'com.figma', appName: 'Figma'));
      await cubit.onAppLaunched((bundleId: 'com.slack', appName: 'Slack'));
    },
    verify: (_) => verifyNever(() => applyRule(any())),
  );
}
