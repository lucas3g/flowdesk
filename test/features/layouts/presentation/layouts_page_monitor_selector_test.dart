import 'package:bloc_test/bloc_test.dart';
import 'package:flowdesk/core/di/injection.dart';
import 'package:flowdesk/core/routing/navigation_cubit.dart';
import 'package:flowdesk/core/theme/app_theme.dart';
import 'package:flowdesk/features/layout_editor/presentation/cubits/layout_editor_cubit.dart';
import 'package:flowdesk/features/layout_editor/presentation/cubits/layout_editor_state.dart';
import 'package:flowdesk/features/layouts/domain/entities/layout.dart';
import 'package:flowdesk/features/layouts/presentation/cubits/applied_layouts_cubit.dart';
import 'package:flowdesk/features/layouts/presentation/cubits/layouts_cubit.dart';
import 'package:flowdesk/features/layouts/presentation/cubits/layouts_state.dart';
import 'package:flowdesk/features/layouts/presentation/pages/layouts_page.dart';
import 'package:flowdesk/features/monitors/domain/entities/monitor.dart';
import 'package:flowdesk/features/monitors/presentation/cubits/monitors_cubit.dart';
import 'package:flowdesk/features/monitors/presentation/cubits/monitors_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/test_fonts.dart';

class _MockLayoutsCubit extends MockCubit<LayoutsState>
    implements LayoutsCubit {}

class _MockMonitorsCubit extends MockCubit<MonitorsState>
    implements MonitorsCubit {}

class _MockAppliedLayoutsCubit extends MockCubit<Map<String, int>>
    implements AppliedLayoutsCubit {}

class _MockLayoutEditorCubit extends MockCubit<LayoutEditorState>
    implements LayoutEditorCubit {}

const _monitor = Monitor(
  id: 1,
  name: 'Principal',
  x: 0,
  y: 0,
  width: 2000,
  height: 1200,
  pixelWidth: 4000,
  pixelHeight: 2400,
  scale: 2,
  refreshRate: 60,
  isPrimary: true,
  isBuiltIn: false,
);

const _layout = Layout(
  id: 7,
  name: 'Metades',
  regions: [LayoutRegion(name: 'A', x: 0, y: 0, width: 100, height: 100)],
);

void main() {
  late _MockLayoutsCubit layoutsCubit;
  late _MockMonitorsCubit monitorsCubit;
  late _MockAppliedLayoutsCubit appliedLayoutsCubit;

  setUpAll(loadMaterialSymbolsFont);

  setUp(() {
    layoutsCubit = _MockLayoutsCubit();
    monitorsCubit = _MockMonitorsCubit();
    appliedLayoutsCubit = _MockAppliedLayoutsCubit();

    whenListen(
      layoutsCubit,
      const Stream<LayoutsState>.empty(),
      initialState: const LayoutsState(
        status: LayoutsStatus.ready,
        layouts: [_layout],
      ),
    );
    when(() => layoutsCubit.load()).thenAnswer((_) async {});
    whenListen(
      monitorsCubit,
      const Stream<MonitorsState>.empty(),
      initialState: const MonitorsState(
        status: MonitorsStatus.ready,
        monitors: [_monitor],
      ),
    );
    whenListen(
      appliedLayoutsCubit,
      const Stream<Map<String, int>>.empty(),
      initialState: {monitorKey(_monitor): _layout.id},
    );

    getIt.registerLazySingleton<LayoutsCubit>(() => layoutsCubit);
    getIt.registerLazySingleton<MonitorsCubit>(() => monitorsCubit);
    getIt.registerLazySingleton<AppliedLayoutsCubit>(() => appliedLayoutsCubit);
    // Resolvidos como campos da página, mesmo sem uso nestes testes.
    getIt.registerLazySingleton<LayoutEditorCubit>(_MockLayoutEditorCubit.new);
    getIt.registerLazySingleton<NavigationCubit>(NavigationCubit.new);
  });

  tearDown(() async => getIt.reset());

  Future<void> pumpPage(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: const Scaffold(body: LayoutsPage()),
      ),
    );
    await tester.pump();
  }

  testWidgets('seletor de monitor aparece mesmo com um único monitor', (
    tester,
  ) async {
    await pumpPage(tester);

    expect(find.text('Aplicar em: Automático'), findsOneWidget);
  });

  testWidgets('menu mostra o layout aplicado e a opção de limpar', (
    tester,
  ) async {
    await pumpPage(tester);

    await tester.tap(find.text('Aplicar em: Automático'));
    await tester.pumpAndSettle();

    expect(find.text('Automático (janela em foco)'), findsOneWidget);
    expect(find.text('Principal'), findsOneWidget);
    expect(find.text('Layout: Metades'), findsOneWidget);
    expect(find.text('Limpar layout de Principal'), findsOneWidget);

    when(
      () => appliedLayoutsCubit.remove(monitorKey(_monitor)),
    ).thenAnswer((_) async {});
    await tester.tap(find.text('Limpar layout de Principal'));
    await tester.pumpAndSettle();

    verify(() => appliedLayoutsCubit.remove(monitorKey(_monitor))).called(1);
  });
}
