import 'package:flowdesk/core/usecases/usecase.dart';
import 'package:flowdesk/features/windows/domain/entities/managed_window.dart';
import 'package:flowdesk/features/windows/domain/usecases/get_windows.dart';
import 'package:flowdesk/features/windows/domain/usecases/move_resize_window.dart';
import 'package:flowdesk/features/windows/presentation/cubits/undo_redo_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class _MockGetWindows extends Mock implements GetWindows {}

class _MockMoveResize extends Mock implements MoveResizeWindow {}

ManagedWindow _window({double x = 0, double y = 0}) => ManagedWindow(
  id: 1,
  pid: 10,
  appName: 'App',
  bundleId: 'com.app',
  title: '',
  x: x,
  y: y,
  width: 800,
  height: 600,
  monitorId: 1,
  isFocused: false,
);

void main() {
  late _MockGetWindows getWindows;
  late _MockMoveResize moveResize;
  late UndoRedoCubit cubit;

  setUpAll(() {
    registerFallbackValue(const NoParams());
    registerFallbackValue(
      MoveResizeParams(window: _window(), x: 0, y: 0, width: 1, height: 1),
    );
  });

  setUp(() {
    getWindows = _MockGetWindows();
    moveResize = _MockMoveResize();
    cubit = UndoRedoCubit(getWindows, moveResize);

    when(() => moveResize(any())).thenAnswer((_) async => right(true));
    // Posição atual da janela após a movimentação.
    when(() => getWindows(any())).thenAnswer(
      (_) async => right([_window(x: 500, y: 300)]),
    );
  });

  tearDown(() => cubit.close());

  test('pushSnapshot habilita undo e limpa o redo', () {
    expect(cubit.state.canUndo, isFalse);

    cubit.pushSnapshot([_window()]);

    expect(cubit.state.canUndo, isTrue);
    expect(cubit.state.canRedo, isFalse);
  });

  test('undo restaura o frame anterior e habilita redo', () async {
    cubit.pushSnapshot([_window(x: 100, y: 50)]);

    await cubit.undo();

    final params =
        verify(() => moveResize(captureAny())).captured.single
            as MoveResizeParams;
    expect(params.x, 100);
    expect(params.y, 50);
    expect(cubit.state.canUndo, isFalse);
    expect(cubit.state.canRedo, isTrue);
  });

  test('redo desfaz o undo voltando ao frame movimentado', () async {
    cubit.pushSnapshot([_window(x: 100, y: 50)]);
    await cubit.undo();

    await cubit.redo();

    final captured = verify(() => moveResize(captureAny())).captured;
    final redoParams = captured.last as MoveResizeParams;
    // Redo restaura a posição capturada no momento do undo (500, 300).
    expect(redoParams.x, 500);
    expect(redoParams.y, 300);
    expect(cubit.state.canUndo, isTrue);
    expect(cubit.state.canRedo, isFalse);
  });

  test('undo sem snapshots é inofensivo', () async {
    await cubit.undo();
    verifyNever(() => moveResize(any()));
  });
}
