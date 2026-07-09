import 'package:bloc_test/bloc_test.dart';
import 'package:flowdesk/core/errors/failures.dart';
import 'package:flowdesk/features/layout_editor/presentation/cubits/layout_editor_cubit.dart';
import 'package:flowdesk/features/layout_editor/presentation/cubits/layout_editor_state.dart';
import 'package:flowdesk/features/layouts/domain/entities/layout.dart';
import 'package:flowdesk/features/layouts/domain/usecases/save_layout.dart';
import 'package:flowdesk/features/layouts/presentation/cubits/layouts_cubit.dart';
import 'package:flowdesk/features/layouts/presentation/cubits/layouts_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class _MockSaveLayout extends Mock implements SaveLayout {}

class _MockLayoutsCubit extends MockCubit<LayoutsState>
    implements LayoutsCubit {}

const _preset = Layout(
  id: 7,
  name: 'Metades',
  isPreset: true,
  shortcut: '⌥9',
  regions: [
    LayoutRegion(id: 1, name: 'Esq.', x: 0, y: 0, width: 50, height: 100),
    LayoutRegion(id: 2, name: 'Dir.', x: 50, y: 0, width: 50, height: 100),
  ],
);

void main() {
  late _MockSaveLayout saveLayout;
  late _MockLayoutsCubit layoutsCubit;

  setUpAll(() => registerFallbackValue(_preset));

  setUp(() {
    saveLayout = _MockSaveLayout();
    layoutsCubit = _MockLayoutsCubit();
    when(() => layoutsCubit.load()).thenAnswer((_) async {});
  });

  LayoutEditorCubit buildCubit() => LayoutEditorCubit(saveLayout, layoutsCubit);

  test('loadForEdit de preset vira cópia editável', () {
    final cubit = buildCubit()..loadForEdit(_preset);

    expect(cubit.state.layout.id, 0);
    expect(cubit.state.layout.name, 'Metades (cópia)');
    expect(cubit.state.layout.isPreset, isFalse);
    expect(cubit.state.layout.shortcut, isNull);
    expect(cubit.state.layout.regions.length, 2);
  });

  test('loadForEdit de layout do usuário mantém o id', () {
    final custom = _preset.copyWith(isPreset: false);
    final cubit = buildCubit()..loadForEdit(custom);

    expect(cubit.state.layout.id, 7);
    expect(cubit.state.isDirty, isFalse);
  });

  test('addRegion adiciona região central e a seleciona', () {
    final cubit = buildCubit()..addRegion();

    expect(cubit.state.layout.regions.length, 1);
    expect(cubit.state.selectedIndex, 0);
    expect(cubit.state.isDirty, isTrue);
    expect(cubit.state.selected!.name, 'Região 1');
  });

  group('setFrame com snap na grade 20×12', () {
    test('alinha aos passos de 5% (x/largura) e 8,33% (y/altura)', () {
      final cubit = buildCubit()..addRegion();

      cubit.setFrame(0, x: 12.4, y: 10, width: 48, height: 30);

      final region = cubit.state.selected!;
      expect(region.x, 10); // 12.4 → passo 5
      expect(region.width, 50); // 48 → passo 5
      expect(region.y, 8.33); // 10 → passo 100/12
      expect(region.height, 33.33); // 30 → 4 linhas
    });

    test('clampa dentro do canvas e respeita tamanho mínimo', () {
      final cubit = buildCubit()..addRegion();

      cubit.setFrame(0, x: 95, y: 95, width: 50, height: 50);

      final region = cubit.state.selected!;
      expect(region.x + region.width, lessThanOrEqualTo(100));
      expect(region.y + region.height, lessThanOrEqualTo(100));
      expect(region.width, greaterThanOrEqualTo(LayoutEditorState.minRegionSize));
    });

    test('sem snap mantém valores livres', () {
      final cubit = buildCubit()
        ..toggleSnap()
        ..addRegion()
        ..setFrame(0, x: 12.4, y: 7.7, width: 41, height: 33);

      final region = cubit.state.selected!;
      expect(region.x, 12.4);
      expect(region.y, 7.7);
    });
  });

  test('addRegionAt ignora arrastos menores que o mínimo', () {
    final cubit = buildCubit()..addRegionAt(10, 10, 4, 4);

    expect(cubit.state.layout.regions, isEmpty);
  });

  test('applyPreset altera o frame da região selecionada', () {
    final cubit = buildCubit()
      ..addRegion()
      ..applyPreset(RegionPreset.leftHalf);

    final region = cubit.state.selected!;
    expect(region.x, 0);
    expect(region.width, 50);
    expect(region.height, 100);
  });

  test('setRegionApp associa e a associação sobrevive a mover/renomear', () {
    final cubit = buildCubit()
      ..addRegion()
      ..setRegionApp(0, bundleId: 'com.vscode', appName: 'VS Code')
      ..setFrame(0, x: 0, y: 0, width: 50, height: 100)
      ..renameRegion(0, 'Editor')
      ..setRegionColor(0, '#30D158');

    final region = cubit.state.selected!;
    expect(region.appBundleId, 'com.vscode');
    expect(region.appName, 'VS Code');
    expect(region.name, 'Editor');
    expect(region.hasApp, isTrue);

    cubit.setRegionApp(0);
    expect(cubit.state.selected!.hasApp, isFalse);
  });

  test('associar app renomeia a região com nome padrão para o app', () {
    final cubit = buildCubit()
      ..addRegion() // vira "Região 1"
      ..setRegionApp(0, bundleId: 'com.vscode', appName: 'VS Code');

    expect(cubit.state.selected!.name, 'VS Code');
  });

  test('associar app preserva um nome de região personalizado', () {
    final cubit = buildCubit()
      ..addRegion()
      ..renameRegion(0, 'Editor Principal')
      ..setRegionApp(0, bundleId: 'com.vscode', appName: 'VS Code');

    expect(cubit.state.selected!.name, 'Editor Principal');
    expect(cubit.state.selected!.appName, 'VS Code');
  });

  test('deleteRegion remove e limpa a seleção', () {
    final cubit = buildCubit()
      ..addRegion()
      ..deleteRegion(0);

    expect(cubit.state.layout.regions, isEmpty);
    expect(cubit.state.selectedIndex, isNull);
  });

  blocTest<LayoutEditorCubit, LayoutEditorState>(
    'save persiste, limpa dirty e recarrega a galeria',
    setUp: () => when(() => saveLayout(any())).thenAnswer(
      (_) async => right(_preset.copyWith(id: 42, isPreset: false)),
    ),
    build: buildCubit,
    seed: () => LayoutEditorState(
      layout: _preset.copyWith(id: 0, isPreset: false),
      isDirty: true,
    ),
    act: (cubit) => cubit.save(),
    expect: () => [
      isA<LayoutEditorState>()
          .having((s) => s.layout.id, 'id', 42)
          .having((s) => s.isDirty, 'isDirty', false)
          .having((s) => s.feedback, 'feedback', contains('salvo')),
    ],
    verify: (_) => verify(() => layoutsCubit.load()).called(1),
  );

  blocTest<LayoutEditorCubit, LayoutEditorState>(
    'save com falha de validação mostra feedback',
    setUp: () => when(() => saveLayout(any())).thenAnswer(
      (_) async => left(
        const ValidationFailure('O layout precisa de ao menos uma região.'),
      ),
    ),
    build: buildCubit,
    act: (cubit) => cubit.save(),
    expect: () => [
      isA<LayoutEditorState>().having(
        (s) => s.feedback,
        'feedback',
        contains('região'),
      ),
    ],
  );
}
