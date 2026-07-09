import 'package:flowdesk/core/errors/failures.dart';
import 'package:flowdesk/features/layouts/domain/entities/layout.dart';
import 'package:flowdesk/features/layouts/domain/repositories/layouts_repository.dart';
import 'package:flowdesk/features/monitors/domain/entities/monitor.dart';
import 'package:flowdesk/features/rules/domain/entities/rule.dart';
import 'package:flowdesk/features/rules/domain/usecases/apply_rule_to_window.dart';
import 'package:flowdesk/features/windows/domain/entities/managed_window.dart';
import 'package:flowdesk/features/windows/domain/repositories/windows_repository.dart';
import 'package:flowdesk/features/windows/domain/usecases/center_window.dart';
import 'package:flowdesk/features/windows/domain/usecases/maximize_window.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class _MockWindowsRepository extends Mock implements WindowsRepository {}

class _MockLayoutsRepository extends Mock implements LayoutsRepository {}

class _MockCenterWindow extends Mock implements CenterWindow {}

class _MockMaximizeWindow extends Mock implements MaximizeWindow {}

Monitor _monitor(int id, String name, {bool primary = false}) => Monitor(
  id: id,
  name: name,
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
  isPrimary: primary,
  isBuiltIn: false,
);

const _window = ManagedWindow(
  id: 1,
  pid: 10,
  appName: 'Slack',
  bundleId: 'com.slack',
  title: '',
  x: 0,
  y: 0,
  width: 600,
  height: 400,
  monitorId: 1,
  isFocused: false,
);

const _layout = Layout(
  id: 9,
  name: 'Metades',
  regions: [
    LayoutRegion(name: 'Esq.', x: 0, y: 0, width: 50, height: 100),
    LayoutRegion(
      name: 'Dir.',
      x: 50,
      y: 0,
      width: 50,
      height: 100,
      sortOrder: 1,
    ),
  ],
);

void main() {
  late _MockWindowsRepository windows;
  late _MockLayoutsRepository layouts;
  late _MockCenterWindow center;
  late _MockMaximizeWindow maximize;
  late ApplyRuleToWindow usecase;

  final monitors = [_monitor(1, 'MacBook', primary: true), _monitor(2, 'Dell 4K')];

  setUpAll(() {
    registerFallbackValue(_window);
    registerFallbackValue(CenterParams(window: _window, monitor: monitors[0]));
    registerFallbackValue(
      MaximizeParams(window: _window, monitor: monitors[0]),
    );
  });

  setUp(() {
    windows = _MockWindowsRepository();
    layouts = _MockLayoutsRepository();
    center = _MockCenterWindow();
    maximize = _MockMaximizeWindow();
    usecase = ApplyRuleToWindow(windows, layouts, center, maximize);

    when(() => center(any())).thenAnswer((_) async => right(true));
    when(() => maximize(any())).thenAnswer((_) async => right(true));
  });

  ApplyRuleParams params(Rule rule) => ApplyRuleParams(
    rule: rule,
    window: _window,
    monitors: monitors,
    gap: 0,
    margin: 8,
  );

  test('moveToMonitor centraliza no monitor de destino pelo nome', () async {
    await usecase(
      params(
        const Rule(
          bundleId: 'com.slack',
          appName: 'Slack',
          actionType: RuleActionType.moveToMonitor,
          targetValue: 'Dell 4K',
        ),
      ),
    );

    final captured =
        verify(() => center(captureAny())).captured.single as CenterParams;
    expect(captured.monitor.name, 'Dell 4K');
  });

  test('moveToMonitor com monitor inexistente falha', () async {
    final result = await usecase(
      params(
        const Rule(
          bundleId: 'com.slack',
          appName: 'Slack',
          actionType: RuleActionType.moveToMonitor,
          targetValue: 'LG Ultrawide',
        ),
      ),
    );

    result.fold(
      (failure) => expect(failure, isA<ValidationFailure>()),
      (_) => fail('deveria falhar'),
    );
  });

  test('maximize usa o monitor atual da janela e a margem', () async {
    await usecase(
      params(
        const Rule(
          bundleId: 'com.slack',
          appName: 'Slack',
          actionType: RuleActionType.maximize,
        ),
      ),
    );

    final captured =
        verify(() => maximize(captureAny())).captured.single as MaximizeParams;
    expect(captured.monitor.id, 1);
    expect(captured.margin, 8);
  });

  test('applyRegion encaixa no frame da região do layout', () async {
    when(() => layouts.getLayouts()).thenAnswer((_) async => right([_layout]));
    when(
      () => windows.setWindowFrame(
        any(),
        x: any(named: 'x'),
        y: any(named: 'y'),
        width: any(named: 'width'),
        height: any(named: 'height'),
      ),
    ).thenAnswer((_) async => right(true));

    await usecase(
      params(
        const Rule(
          bundleId: 'com.slack',
          appName: 'Slack',
          actionType: RuleActionType.applyRegion,
          targetValue: '9:1',
        ),
      ),
    );

    // Região direita (50%) da área útil com margem 8:
    // área = 984×784 a partir de (8,8); x = 8 + 0.5*984 = 500.
    verify(
      () => windows.setWindowFrame(_window, x: 500, y: 8, width: 492, height: 784),
    ).called(1);
  });

  test('applyRegion com região removida falha', () async {
    when(() => layouts.getLayouts()).thenAnswer((_) async => right([_layout]));

    final result = await usecase(
      params(
        const Rule(
          bundleId: 'com.slack',
          appName: 'Slack',
          actionType: RuleActionType.applyRegion,
          targetValue: '9:5',
        ),
      ),
    );

    result.fold(
      (failure) => expect(failure, isA<ValidationFailure>()),
      (_) => fail('deveria falhar'),
    );
  });
}
