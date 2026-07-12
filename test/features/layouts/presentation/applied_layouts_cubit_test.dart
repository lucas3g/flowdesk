import 'package:bloc_test/bloc_test.dart';
import 'package:flowdesk/core/errors/failures.dart';
import 'package:flowdesk/core/usecases/usecase.dart';
import 'package:flowdesk/features/layouts/domain/usecases/applied_layouts_usecases.dart';
import 'package:flowdesk/features/layouts/presentation/cubits/applied_layouts_cubit.dart';
import 'package:flowdesk/features/monitors/domain/entities/monitor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class _MockGetAppliedLayouts extends Mock implements GetAppliedLayouts {}

class _MockSetAppliedLayout extends Mock implements SetAppliedLayout {}

class _MockRemoveAppliedLayout extends Mock implements RemoveAppliedLayout {}

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

void main() {
  late _MockGetAppliedLayouts getApplied;
  late _MockSetAppliedLayout setApplied;
  late _MockRemoveAppliedLayout removeApplied;

  setUpAll(() {
    registerFallbackValue(const NoParams());
    registerFallbackValue(
      const SetAppliedLayoutParams(monitorKey: '', layoutId: 0),
    );
  });

  setUp(() {
    getApplied = _MockGetAppliedLayouts();
    setApplied = _MockSetAppliedLayout();
    removeApplied = _MockRemoveAppliedLayout();

    when(
      () => getApplied(any()),
    ).thenAnswer((_) async => right({'Principal:4000x2400': 7}));
    when(() => setApplied(any())).thenAnswer((_) async => right(unit));
    when(() => removeApplied(any())).thenAnswer((_) async => right(unit));
  });

  AppliedLayoutsCubit buildCubit() =>
      AppliedLayoutsCubit(getApplied, setApplied, removeApplied);

  blocTest<AppliedLayoutsCubit, Map<String, int>>(
    'load carrega o mapa persistido',
    build: buildCubit,
    act: (cubit) => cubit.load(),
    expect: () => [
      {'Principal:4000x2400': 7},
    ],
  );

  blocTest<AppliedLayoutsCubit, Map<String, int>>(
    'set acumula por monitor sem apagar os demais',
    build: buildCubit,
    seed: () => const {'Principal:4000x2400': 7},
    act: (cubit) => cubit.set('Externo:1920x1080', 8),
    expect: () => [
      {'Principal:4000x2400': 7, 'Externo:1920x1080': 8},
    ],
    verify: (_) => verify(
      () => setApplied(
        const SetAppliedLayoutParams(
          monitorKey: 'Externo:1920x1080',
          layoutId: 8,
        ),
      ),
    ).called(1),
  );

  blocTest<AppliedLayoutsCubit, Map<String, int>>(
    'remove limpa apenas o monitor pedido',
    build: buildCubit,
    seed: () => const {'Principal:4000x2400': 7, 'Externo:1920x1080': 8},
    act: (cubit) => cubit.remove('Externo:1920x1080'),
    expect: () => [
      {'Principal:4000x2400': 7},
    ],
    verify: (_) => verify(() => removeApplied('Externo:1920x1080')).called(1),
  );

  blocTest<AppliedLayoutsCubit, Map<String, int>>(
    'falha ao persistir não altera o estado',
    build: buildCubit,
    setUp: () => when(
      () => setApplied(any()),
    ).thenAnswer((_) async => left(const DatabaseFailure('erro'))),
    act: (cubit) => cubit.set('Principal:4000x2400', 7),
    expect: () => const <Map<String, int>>[],
  );

  test('layoutIdFor resolve pelo monitorKey', () {
    final cubit = buildCubit()..emit(const {'Principal:4000x2400': 7});
    expect(cubit.layoutIdFor(_monitor), 7);
    expect(monitorKey(_monitor), 'Principal:4000x2400');
  });
}
