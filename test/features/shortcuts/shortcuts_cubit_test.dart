import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flowdesk/features/layouts/domain/entities/layout.dart';
import 'package:flowdesk/features/layouts/presentation/cubits/layouts_cubit.dart';
import 'package:flowdesk/features/layouts/presentation/cubits/layouts_state.dart';
import 'package:flowdesk/features/shortcuts/domain/entities/shortcut_binding.dart';
import 'package:flowdesk/features/shortcuts/domain/usecases/register_shortcuts.dart';
import 'package:flowdesk/features/shortcuts/domain/usecases/watch_shortcut_presses.dart';
import 'package:flowdesk/features/shortcuts/presentation/cubits/shortcuts_cubit.dart';
import 'package:flowdesk/features/shortcuts/presentation/cubits/shortcuts_state.dart';
import 'package:flowdesk/features/workspaces/domain/entities/workspace.dart';
import 'package:flowdesk/features/workspaces/presentation/cubits/workspaces_cubit.dart';
import 'package:flowdesk/features/workspaces/presentation/cubits/workspaces_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class _MockRegisterShortcuts extends Mock implements RegisterShortcuts {}

class _MockWatchPresses extends Mock implements WatchShortcutPresses {}

class _MockLayoutsCubit extends MockCubit<LayoutsState>
    implements LayoutsCubit {}

class _MockWorkspacesCubit extends MockCubit<WorkspacesState>
    implements WorkspacesCubit {}

const _layout = Layout(
  id: 1,
  name: 'Código & Terminal',
  shortcut: '⌥1',
  regions: [LayoutRegion(name: 'A', x: 0, y: 0, width: 100, height: 100)],
);

const _workspace = Workspace(id: 5, name: 'Dev', shortcut: '⌃1');

void main() {
  late _MockRegisterShortcuts registerShortcuts;
  late _MockWatchPresses watchPresses;
  late _MockLayoutsCubit layoutsCubit;
  late _MockWorkspacesCubit workspacesCubit;
  late StreamController<int> presses;

  setUpAll(() {
    registerFallbackValue(_layout);
    registerFallbackValue(_workspace);
    registerFallbackValue(const <ShortcutBinding>[]);
  });

  setUp(() {
    registerShortcuts = _MockRegisterShortcuts();
    watchPresses = _MockWatchPresses();
    layoutsCubit = _MockLayoutsCubit();
    workspacesCubit = _MockWorkspacesCubit();
    presses = StreamController<int>.broadcast();

    when(() => registerShortcuts(any())).thenAnswer((_) async => right(unit));
    when(() => watchPresses()).thenAnswer((_) => presses.stream);
    when(() => layoutsCubit.state).thenReturn(
      const LayoutsState(
        status: LayoutsStatus.ready,
        // Layout sem atalho não deve gerar binding.
        layouts: [_layout, Layout(id: 2, name: 'Sem atalho')],
      ),
    );
    when(() => workspacesCubit.state).thenReturn(
      const WorkspacesState(
        status: WorkspacesStatus.ready,
        workspaces: [_workspace],
      ),
    );
    when(() => layoutsCubit.apply(any())).thenAnswer((_) async {});
    when(() => workspacesCubit.apply(any())).thenAnswer((_) async {});
  });

  tearDown(() => presses.close());

  ShortcutsCubit buildCubit() => ShortcutsCubit(
    registerShortcuts,
    watchPresses,
    layoutsCubit,
    workspacesCubit,
  );

  blocTest<ShortcutsCubit, ShortcutsState>(
    'sync registra apenas atalhos parseáveis (layout ⌥1 e workspace ⌃1)',
    build: buildCubit,
    act: (cubit) => cubit.start(),
    expect: () => [
      isA<ShortcutsState>()
          .having((s) => s.status, 'status', ShortcutsStatus.ready)
          .having((s) => s.bindings.length, 'bindings', 2),
    ],
    verify: (_) {
      final registered =
          verify(() => registerShortcuts(captureAny())).captured.single
              as List<ShortcutBinding>;
      expect(registered.length, 2);
      expect(registered[0].type, ShortcutActionType.applyLayout);
      expect(registered[0].targetId, 1);
      expect(registered[1].type, ShortcutActionType.applyWorkspace);
      expect(registered[1].targetId, 5);
    },
  );

  blocTest<ShortcutsCubit, ShortcutsState>(
    'acionamento do hotkey aplica o layout correspondente',
    build: buildCubit,
    act: (cubit) async {
      await cubit.start();
      presses.add(1); // primeiro binding = layout
      await Future<void>.delayed(Duration.zero);
    },
    verify: (_) {
      verify(() => layoutsCubit.apply(_layout)).called(1);
      verifyNever(() => workspacesCubit.apply(any()));
    },
  );

  blocTest<ShortcutsCubit, ShortcutsState>(
    'acionamento do hotkey ativa o workspace correspondente',
    build: buildCubit,
    act: (cubit) async {
      await cubit.start();
      presses.add(2); // segundo binding = workspace
      await Future<void>.delayed(Duration.zero);
    },
    verify: (_) => verify(() => workspacesCubit.apply(_workspace)).called(1),
  );

  blocTest<ShortcutsCubit, ShortcutsState>(
    'sync sem mudanças não registra novamente',
    build: buildCubit,
    act: (cubit) async {
      await cubit.start();
      await cubit.sync();
      await cubit.sync();
    },
    verify: (_) => verify(() => registerShortcuts(any())).called(1),
  );
}
