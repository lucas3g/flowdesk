import 'package:flowdesk/core/errors/failures.dart';
import 'package:flowdesk/features/layouts/domain/entities/layout.dart';
import 'package:flowdesk/features/layouts/domain/repositories/layouts_repository.dart';
import 'package:flowdesk/features/monitors/domain/entities/monitor.dart';
import 'package:flowdesk/features/windows/domain/entities/managed_window.dart';
import 'package:flowdesk/features/windows/domain/repositories/windows_repository.dart';
import 'package:flowdesk/features/workspaces/domain/entities/workspace.dart';
import 'package:flowdesk/features/workspaces/domain/repositories/apps_launcher_repository.dart';
import 'package:flowdesk/features/workspaces/domain/repositories/workspaces_repository.dart';
import 'package:flowdesk/features/workspaces/domain/usecases/apply_workspace.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class _MockLayoutsRepository extends Mock implements LayoutsRepository {}

class _MockWindowsRepository extends Mock implements WindowsRepository {}

class _MockLauncher extends Mock implements AppsLauncherRepository {}

class _MockWorkspacesRepository extends Mock implements WorkspacesRepository {}

const _monitor = Monitor(
  id: 1,
  name: 'Principal',
  x: 0,
  y: 0,
  width: 2000,
  height: 1000,
  visibleWidth: 2000,
  visibleHeight: 1000,
  pixelWidth: 2000,
  pixelHeight: 1000,
  scale: 1,
  refreshRate: 60,
  isPrimary: true,
  isBuiltIn: false,
);

const _layout = Layout(
  id: 10,
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

const _workspace = Workspace(
  id: 3,
  name: 'Dev',
  layoutId: 10,
  apps: [
    WorkspaceApp(bundleId: 'com.a', appName: 'App A'),
    WorkspaceApp(bundleId: 'com.b', appName: 'App B', sortOrder: 1),
  ],
);

ManagedWindow _window(String bundleId, {double width = 800}) => ManagedWindow(
  id: bundleId.hashCode,
  pid: 1,
  appName: bundleId,
  bundleId: bundleId,
  title: '',
  x: 0,
  y: 0,
  width: width,
  height: 600,
  monitorId: 1,
  isFocused: false,
);

void main() {
  late _MockLayoutsRepository layouts;
  late _MockWindowsRepository windows;
  late _MockLauncher launcher;
  late _MockWorkspacesRepository workspaces;
  late ApplyWorkspace usecase;

  setUpAll(() => registerFallbackValue(_window('fallback')));

  setUp(() {
    layouts = _MockLayoutsRepository();
    windows = _MockWindowsRepository();
    launcher = _MockLauncher();
    workspaces = _MockWorkspacesRepository();
    usecase = ApplyWorkspace(layouts, windows, launcher, workspaces);

    when(() => layouts.getLayouts()).thenAnswer((_) async => right([_layout]));
    when(() => workspaces.setActive(any())).thenAnswer((_) async => right(unit));
    when(
      () => windows.setWindowFrame(
        any(),
        x: any(named: 'x'),
        y: any(named: 'y'),
        width: any(named: 'width'),
        height: any(named: 'height'),
      ),
    ).thenAnswer((_) async => right(true));
  });

  ApplyWorkspaceParams params() => const ApplyWorkspaceParams(
    workspace: _workspace,
    monitor: _monitor,
    pollInterval: Duration(milliseconds: 1),
    maxPollAttempts: 3,
  );

  test('abre o app que falta, aguarda a janela e posiciona os dois', () async {
    // App A já aberto; App B abre e a janela aparece no segundo poll.
    var calls = 0;
    when(() => windows.getWindows()).thenAnswer((_) async {
      calls++;
      return right(
        calls >= 3
            ? [_window('com.a'), _window('com.b')]
            : [_window('com.a')],
      );
    });
    when(() => launcher.launchApp('com.b')).thenAnswer((_) async => right(true));

    final result = await usecase(params());

    final applied = result.getOrElse((f) => fail(f.message));
    expect(applied.positioned, 2);
    expect(applied.missingApps, isEmpty);
    verify(() => launcher.launchApp('com.b')).called(1);
    verifyNever(() => launcher.launchApp('com.a'));
    verify(() => workspaces.setActive(3)).called(1);
  });

  test('app que não abre entra em missingApps após o timeout', () async {
    when(() => windows.getWindows()).thenAnswer(
      (_) async => right([_window('com.a')]),
    );
    when(() => launcher.launchApp('com.b')).thenAnswer((_) async => right(false));

    final result = await usecase(params());

    final applied = result.getOrElse((f) => fail(f.message));
    expect(applied.positioned, 1);
    expect(applied.missingApps, ['App B']);
  });

  test('usa a janela principal (maior) quando o app tem várias', () async {
    when(() => windows.getWindows()).thenAnswer(
      (_) async => right([
        _window('com.a', width: 300),
        _window('com.a', width: 1200),
        _window('com.b'),
      ]),
    );

    await usecase(params());

    final captured = verify(
      () => windows.setWindowFrame(
        captureAny(),
        x: any(named: 'x'),
        y: any(named: 'y'),
        width: any(named: 'width'),
        height: any(named: 'height'),
      ),
    ).captured;
    final firstWindow = captured.first as ManagedWindow;
    expect(firstWindow.width, 1200);
  });

  test('workspace sem layout vinculado falha com ValidationFailure', () async {
    final result = await usecase(
      ApplyWorkspaceParams(
        workspace: _workspace.copyWith(layoutId: () => null),
        monitor: _monitor,
      ),
    );

    result.fold(
      (failure) => expect(failure, isA<ValidationFailure>()),
      (_) => fail('deveria falhar'),
    );
  });

  test('workspace sem apps falha com ValidationFailure', () async {
    final result = await usecase(
      ApplyWorkspaceParams(
        workspace: _workspace.copyWith(apps: const []),
        monitor: _monitor,
      ),
    );

    result.fold(
      (failure) => expect(failure, isA<ValidationFailure>()),
      (_) => fail('deveria falhar'),
    );
  });
}
