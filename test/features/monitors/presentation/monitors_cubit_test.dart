import 'package:bloc_test/bloc_test.dart';
import 'package:flowdesk/core/errors/failures.dart';
import 'package:flowdesk/core/usecases/usecase.dart';
import 'package:flowdesk/features/monitors/domain/entities/monitor.dart';
import 'package:flowdesk/features/monitors/domain/usecases/get_monitors.dart';
import 'package:flowdesk/features/monitors/domain/usecases/watch_monitors.dart';
import 'package:flowdesk/features/monitors/presentation/cubits/monitors_cubit.dart';
import 'package:flowdesk/features/monitors/presentation/cubits/monitors_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class _MockGetMonitors extends Mock implements GetMonitors {}

class _MockWatchMonitors extends Mock implements WatchMonitors {}

Monitor _monitor(int id, {bool primary = false}) => Monitor(
  id: id,
  name: 'Monitor $id',
  x: 0,
  y: 0,
  width: 1920,
  height: 1080,
  pixelWidth: 3840,
  pixelHeight: 2160,
  scale: 2,
  refreshRate: 60,
  isPrimary: primary,
  isBuiltIn: false,
);

void main() {
  late _MockGetMonitors getMonitors;
  late _MockWatchMonitors watchMonitors;

  setUpAll(() => registerFallbackValue(const NoParams()));

  setUp(() {
    getMonitors = _MockGetMonitors();
    watchMonitors = _MockWatchMonitors();
    when(() => watchMonitors(any())).thenAnswer((_) => const Stream.empty());
  });

  MonitorsCubit buildCubit() => MonitorsCubit(getMonitors, watchMonitors);

  blocTest<MonitorsCubit, MonitorsState>(
    'start carrega a lista e assina o stream de mudanças',
    setUp: () => when(() => getMonitors(any())).thenAnswer(
      (_) async => right([_monitor(1, primary: true), _monitor(2)]),
    ),
    build: buildCubit,
    act: (cubit) => cubit.start(),
    expect: () => [
      isA<MonitorsState>()
          .having((s) => s.status, 'status', MonitorsStatus.ready)
          .having((s) => s.monitors.length, 'monitors', 2)
          .having((s) => s.totalPixelWidth, 'totalPixelWidth', 7680),
    ],
    verify: (_) => verify(() => watchMonitors(any())).called(1),
  );

  blocTest<MonitorsCubit, MonitorsState>(
    'eventos do stream atualizam a lista (monitor conectado)',
    setUp: () {
      when(() => getMonitors(any())).thenAnswer(
        (_) async => right([_monitor(1, primary: true)]),
      );
      when(() => watchMonitors(any())).thenAnswer(
        (_) => Stream.value(
          right([_monitor(1, primary: true), _monitor(2)]),
        ),
      );
    },
    build: buildCubit,
    act: (cubit) => cubit.start(),
    expect: () => [
      isA<MonitorsState>().having((s) => s.monitors.length, 'monitors', 1),
      isA<MonitorsState>().having((s) => s.monitors.length, 'monitors', 2),
    ],
  );

  blocTest<MonitorsCubit, MonitorsState>(
    'select alterna a seleção do monitor',
    build: buildCubit,
    seed: () => MonitorsState(
      status: MonitorsStatus.ready,
      monitors: [_monitor(1), _monitor(2)],
    ),
    act: (cubit) => cubit
      ..select(2)
      ..select(2),
    expect: () => [
      isA<MonitorsState>().having((s) => s.selectedId, 'selectedId', 2),
      isA<MonitorsState>().having((s) => s.selectedId, 'selectedId', isNull),
    ],
  );

  blocTest<MonitorsCubit, MonitorsState>(
    'limpa a seleção quando o monitor selecionado é desconectado',
    setUp: () => when(() => getMonitors(any())).thenAnswer(
      (_) async => right([_monitor(1, primary: true)]),
    ),
    build: buildCubit,
    seed: () => MonitorsState(
      status: MonitorsStatus.ready,
      monitors: [_monitor(1, primary: true), _monitor(2)],
      selectedId: 2,
    ),
    act: (cubit) => cubit.refresh(),
    expect: () => [
      isA<MonitorsState>()
          .having((s) => s.monitors.length, 'monitors', 1)
          .having((s) => s.selectedId, 'selectedId', isNull),
    ],
  );

  blocTest<MonitorsCubit, MonitorsState>(
    'refresh com falha emite estado de erro',
    setUp: () => when(() => getMonitors(any())).thenAnswer(
      (_) async => left(const PlatformFailure('canal indisponível')),
    ),
    build: buildCubit,
    act: (cubit) => cubit.refresh(),
    expect: () => [
      isA<MonitorsState>()
          .having((s) => s.status, 'status', MonitorsStatus.error)
          .having((s) => s.errorMessage, 'errorMessage', 'canal indisponível'),
    ],
  );
}
