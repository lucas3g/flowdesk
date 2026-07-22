import 'package:bloc_test/bloc_test.dart';
import 'package:flowdesk/core/services/region_cycle_service.dart';
import 'package:flowdesk/core/usecases/usecase.dart';
import 'package:flowdesk/features/layouts/domain/entities/layout.dart';
import 'package:flowdesk/features/layouts/domain/usecases/apply_layout.dart';
import 'package:flowdesk/features/layouts/domain/usecases/get_layouts.dart';
import 'package:flowdesk/features/layouts/presentation/cubits/applied_layouts_cubit.dart';
import 'package:flowdesk/features/monitors/domain/entities/monitor.dart';
import 'package:flowdesk/features/monitors/presentation/cubits/monitors_cubit.dart';
import 'package:flowdesk/features/monitors/presentation/cubits/monitors_state.dart';
import 'package:flowdesk/features/settings/domain/entities/app_settings.dart';
import 'package:flowdesk/features/settings/presentation/cubits/settings_cubit.dart';
import 'package:flowdesk/features/settings/presentation/cubits/settings_state.dart';
import 'package:flowdesk/features/windows/domain/entities/managed_window.dart';
import 'package:flowdesk/features/windows/domain/repositories/windows_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class _MockSettingsCubit extends MockCubit<SettingsState>
    implements SettingsCubit {}

class _MockMonitorsCubit extends MockCubit<MonitorsState>
    implements MonitorsCubit {}

class _MockAppliedLayoutsCubit extends MockCubit<Map<String, int>>
    implements AppliedLayoutsCubit {}

class _MockGetLayouts extends Mock implements GetLayouts {}

class _MockWindowsRepository extends Mock implements WindowsRepository {}

const _monitor = Monitor(
  id: 1,
  name: 'Principal',
  x: 0,
  y: 0,
  width: 2000,
  height: 1200,
  visibleX: 0,
  visibleY: 0,
  visibleWidth: 2000,
  visibleHeight: 1000,
  pixelWidth: 4000,
  pixelHeight: 2400,
  scale: 2,
  refreshRate: 60,
  isPrimary: true,
  isBuiltIn: false,
);

const _layout = Layout(
  id: 7,
  name: 'Terços',
  regions: [
    LayoutRegion(name: 'A', x: 0, y: 0, width: 34, height: 100),
    LayoutRegion(name: 'B', x: 34, y: 0, width: 33, height: 100),
    LayoutRegion(name: 'C', x: 67, y: 0, width: 33, height: 100),
  ],
);

ManagedWindow _window({
  required double x,
  required double y,
  required double width,
  required double height,
  bool isFocused = true,
}) => ManagedWindow(
  id: 10,
  pid: 100,
  appName: 'App',
  bundleId: 'com.app',
  title: 'Janela',
  x: x,
  y: y,
  width: width,
  height: height,
  monitorId: 1,
  isFocused: isFocused,
);

void main() {
  late _MockSettingsCubit settingsCubit;
  late _MockMonitorsCubit monitorsCubit;
  late _MockAppliedLayoutsCubit appliedLayoutsCubit;
  late _MockGetLayouts getLayouts;
  late _MockWindowsRepository windowsRepository;

  setUpAll(() {
    registerFallbackValue(const NoParams());
    registerFallbackValue(_window(x: 0, y: 0, width: 1, height: 1));
  });

  setUp(() {
    settingsCubit = _MockSettingsCubit();
    monitorsCubit = _MockMonitorsCubit();
    appliedLayoutsCubit = _MockAppliedLayoutsCubit();
    getLayouts = _MockGetLayouts();
    windowsRepository = _MockWindowsRepository();

    when(() => monitorsCubit.state).thenReturn(
      const MonitorsState(status: MonitorsStatus.ready, monitors: [_monitor]),
    );
    when(() => appliedLayoutsCubit.layoutIdFor(_monitor)).thenReturn(7);
    when(() => getLayouts(any())).thenAnswer((_) async => right([_layout]));
    when(() => settingsCubit.state).thenReturn(
      const SettingsState(
        status: SettingsStatus.ready,
        settings: AppSettings(windowGap: 0, screenMargin: 0),
      ),
    );
    when(
      () => windowsRepository.setWindowFrame(
        any(),
        x: any(named: 'x'),
        y: any(named: 'y'),
        width: any(named: 'width'),
        height: any(named: 'height'),
        settle: any(named: 'settle'),
      ),
    ).thenAnswer((_) async => right(true));
  });

  RegionCycleService buildService() => RegionCycleService(
    settingsCubit,
    monitorsCubit,
    appliedLayoutsCubit,
    getLayouts,
    windowsRepository,
  );

  void stubFocused(ManagedWindow window) {
    when(
      () => windowsRepository.getWindows(),
    ).thenAnswer((_) async => right([window]));
  }

  // Frames esperados dos terços (gap/margem 0): A=0..680, B=680..1340, C=1340..2000.
  RegionFrame frameOf(int index) =>
      regionFrameOnMonitor(_layout.regions[index], _monitor);

  void expectMovedTo(RegionFrame frame) {
    verify(
      () => windowsRepository.setWindowFrame(
        any(),
        x: frame.x,
        y: frame.y,
        width: frame.width,
        height: frame.height,
        settle: any(named: 'settle'),
      ),
    ).called(1);
  }

  group('cycleTargetIndex', () {
    final frames = [for (var i = 0; i < 3; i++) frameOf(i)];

    test('janela fora das regiões vai para a mais próxima', () {
      final target = cycleTargetIndex(frames, (
        x: 1500,
        y: 100,
        width: 300,
        height: 300,
      ), CycleDirection.next);
      expect(target, 2);
    });

    test('janela em uma região avança na direção pedida', () {
      final inFirst = (
        x: frames[0].x,
        y: frames[0].y,
        width: frames[0].width,
        height: frames[0].height,
      );
      expect(cycleTargetIndex(frames, inFirst, CycleDirection.next), 1);
    });

    test('dá a volta nas pontas', () {
      final inLast = (
        x: frames[2].x,
        y: frames[2].y,
        width: frames[2].width,
        height: frames[2].height,
      );
      expect(cycleTargetIndex(frames, inLast, CycleDirection.next), 0);

      final inFirst = (
        x: frames[0].x,
        y: frames[0].y,
        width: frames[0].width,
        height: frames[0].height,
      );
      expect(cycleTargetIndex(frames, inFirst, CycleDirection.previous), 2);
    });

    test('pequenos desvios ainda contam como dentro da região', () {
      // Bordas invisíveis do DWM/ajustes do app deslocam alguns pixels.
      final near = (
        x: frames[1].x + 7,
        y: frames[1].y - 5,
        width: frames[1].width + 6,
        height: frames[1].height - 7,
      );
      expect(cycleTargetIndex(frames, near, CycleDirection.next), 2);
    });

    test('currentIndex explícito tem prioridade sobre o frame', () {
      final target = cycleTargetIndex(
        frames,
        (x: 0, y: 0, width: 100, height: 100),
        CycleDirection.next,
        currentIndex: 1,
      );
      expect(target, 2);
    });
  });

  group('RegionCycleService.cycle', () {
    test('move a janela focada para a região mais próxima', () async {
      stubFocused(_window(x: 700, y: 50, width: 400, height: 400));

      await buildService().cycle(CycleDirection.next);

      expectMovedTo(frameOf(1));
    });

    test('pressionar de novo avança para a próxima região', () async {
      final second = frameOf(1);
      stubFocused(
        _window(
          x: second.x,
          y: second.y,
          width: second.width,
          height: second.height,
        ),
      );

      await buildService().cycle(CycleDirection.next);

      expectMovedTo(frameOf(2));
    });

    test('sem layout aplicado no monitor da janela não move nada', () async {
      when(() => appliedLayoutsCubit.layoutIdFor(_monitor)).thenReturn(null);
      stubFocused(_window(x: 0, y: 0, width: 400, height: 400));

      await buildService().cycle(CycleDirection.next);

      verifyNever(
        () => windowsRepository.setWindowFrame(
          any(),
          x: any(named: 'x'),
          y: any(named: 'y'),
          width: any(named: 'width'),
          height: any(named: 'height'),
        ),
      );
    });

    test(
      'continua o ciclo mesmo quando o app ajusta o próprio frame',
      () async {
        final service = buildService();
        final second = frameOf(1);

        // 1º acionamento: janela solta perto da região B → encaixa em B.
        stubFocused(_window(x: 700, y: 50, width: 400, height: 400));
        await service.cycle(CycleDirection.next);
        expectMovedTo(second);

        // O app "obedeceu torto" (frame reportado bem fora da tolerância, mas
        // o centro segue na região B). O 2º acionamento deve avançar para C.
        stubFocused(
          _window(
            x: second.x + 30,
            y: second.y + 20,
            width: second.width - 60,
            height: second.height - 40,
          ),
        );
        await service.cycle(CycleDirection.next);
        expectMovedTo(frameOf(2));
      },
    );

    test(
      'janela arrastada para longe recomeça da região mais próxima',
      () async {
        final service = buildService();

        // Ciclo deixa a janela na região B (índice 1 lembrado).
        stubFocused(_window(x: 700, y: 50, width: 400, height: 400));
        await service.cycle(CycleDirection.next);

        // Usuário arrastou a janela para cima da região A: memória invalidada,
        // volta a valer a região mais próxima.
        stubFocused(_window(x: 50, y: 50, width: 300, height: 300));
        await service.cycle(CycleDirection.next);
        expectMovedTo(frameOf(0));
      },
    );

    test('regiões são percorridas em ordem de leitura (linhas)', () async {
      // Dois em cima, um embaixo ocupando a largura toda.
      const grid = Layout(
        id: 7,
        name: 'Grade',
        regions: [
          LayoutRegion(name: 'Baixo', x: 0, y: 50, width: 100, height: 50),
          LayoutRegion(name: 'Esq.', x: 0, y: 0, width: 50, height: 50),
          LayoutRegion(name: 'Dir.', x: 50, y: 0, width: 50, height: 50),
        ],
      );
      when(() => getLayouts(any())).thenAnswer((_) async => right([grid]));

      final topLeft = regionFrameOnMonitor(grid.regions[1], _monitor);
      stubFocused(
        _window(
          x: topLeft.x,
          y: topLeft.y,
          width: topLeft.width,
          height: topLeft.height,
        ),
      );

      await buildService().cycle(CycleDirection.next);

      // Do canto superior esquerdo, a próxima é o superior direito —
      // não a de baixo.
      expectMovedTo(regionFrameOnMonitor(grid.regions[2], _monitor));
    });

    test('sem janela focada não move nada', () async {
      stubFocused(
        _window(x: 0, y: 0, width: 400, height: 400, isFocused: false),
      );

      await buildService().cycle(CycleDirection.next);

      verifyNever(
        () => windowsRepository.setWindowFrame(
          any(),
          x: any(named: 'x'),
          y: any(named: 'y'),
          width: any(named: 'width'),
          height: any(named: 'height'),
        ),
      );
    });
  });
}
