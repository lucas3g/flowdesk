import 'package:injectable/injectable.dart';

import '../../features/layouts/domain/usecases/apply_layout.dart';
import '../../features/layouts/domain/usecases/get_layouts.dart';
import '../../features/layouts/presentation/cubits/applied_layouts_cubit.dart';
import '../../features/monitors/presentation/cubits/monitors_cubit.dart';
import '../../features/settings/presentation/cubits/settings_cubit.dart';
import '../../features/windows/domain/entities/managed_window.dart';
import '../../features/windows/domain/repositories/windows_repository.dart';
import '../usecases/usecase.dart';

/// Direção do ciclo entre regiões (setas ← e →).
enum CycleDirection { previous, next }

/// Tolerância (px) para considerar que a janela já ocupa uma região — folga
/// para bordas invisíveis do DWM (Windows) e apps que ajustam o próprio
/// tamanho ao serem redimensionados.
const double _frameTolerance = 8;

/// Índice da região cujo frame coincide com o da janela (dentro da
/// tolerância); null quando a janela não ocupa nenhuma região.
int? regionIndexOfFrame(
  List<RegionFrame> frames,
  ({double x, double y, double width, double height}) windowFrame,
) {
  for (var i = 0; i < frames.length; i++) {
    final frame = frames[i];
    final matches =
        (frame.x - windowFrame.x).abs() <= _frameTolerance &&
        (frame.y - windowFrame.y).abs() <= _frameTolerance &&
        (frame.width - windowFrame.width).abs() <= _frameTolerance &&
        (frame.height - windowFrame.height).abs() <= _frameTolerance;
    if (matches) return i;
  }
  return null;
}

/// Índice da região alvo ao ciclar: partindo de [currentIndex] (ou da região
/// cujo frame coincide com o da janela), avança para a adjacente na direção
/// pedida, dando a volta nas pontas; sem região atual, vai para a região de
/// centro mais próximo. [frames] deve estar em ordem de leitura.
int cycleTargetIndex(
  List<RegionFrame> frames,
  ({double x, double y, double width, double height}) windowFrame,
  CycleDirection direction, {
  int? currentIndex,
}) {
  assert(frames.isNotEmpty);

  final current = currentIndex ?? regionIndexOfFrame(frames, windowFrame);
  if (current != null) {
    final step = direction == CycleDirection.next ? 1 : -1;
    return (current + step + frames.length) % frames.length;
  }

  // Fora de qualquer região: escolhe a de centro mais próximo.
  final centerX = windowFrame.x + windowFrame.width / 2;
  final centerY = windowFrame.y + windowFrame.height / 2;
  var nearest = 0;
  var nearestDistance = double.infinity;
  for (var i = 0; i < frames.length; i++) {
    final frame = frames[i];
    final dx = frame.x + frame.width / 2 - centerX;
    final dy = frame.y + frame.height / 2 - centerY;
    final distance = dx * dx + dy * dy;
    if (distance < nearestDistance) {
      nearestDistance = distance;
      nearest = i;
    }
  }
  return nearest;
}

/// Move a janela em foco entre as regiões do layout aplicado no monitor
/// em que ela está, acionado pelos atalhos globais ⌘⌥←/→
/// (Ctrl+Win+←/→ no Windows).
@lazySingleton
class RegionCycleService {
  RegionCycleService(
    this._settingsCubit,
    this._monitorsCubit,
    this._appliedLayoutsCubit,
    this._getLayouts,
    this._windowsRepository,
  );

  final SettingsCubit _settingsCubit;
  final MonitorsCubit _monitorsCubit;
  final AppliedLayoutsCubit _appliedLayoutsCubit;
  final GetLayouts _getLayouts;
  final WindowsRepository _windowsRepository;

  /// Evita reentrância enquanto um movimento ainda está em andamento.
  bool _busy = false;

  /// Última região para onde cada janela foi enviada pelo ciclo — permite
  /// continuar avançando mesmo quando o app ajusta o próprio frame (comum no
  /// Windows) e o frame reportado não coincide mais com o da região.
  final Map<int, int> _lastIndexByWindow = {};

  /// Assinatura dos frames usados na última chamada; quando muda (outro
  /// layout, gap ou monitor), a memória de posições deixa de valer.
  String? _framesKey;

  Future<void> cycle(CycleDirection direction) async {
    if (_busy) return;
    _busy = true;
    try {
      await _cycle(direction);
    } finally {
      _busy = false;
    }
  }

  Future<void> _cycle(CycleDirection direction) async {
    final windowsResult = await _windowsRepository.getWindows();
    final focused = windowsResult
        .getOrElse((_) => const [])
        .where((window) => window.isFocused && !window.isMinimized)
        .firstOrNull;
    if (focused == null) return;

    // O ciclo usa o layout aplicado no monitor em que a janela em foco
    // está — cada monitor pode ter um layout diferente.
    final monitor = _monitorsCubit.state.monitors
        .where((monitor) => monitor.id == focused.monitorId)
        .firstOrNull;
    if (monitor == null) return;

    final layoutId = _appliedLayoutsCubit.layoutIdFor(monitor);
    if (layoutId == null) return;

    final layoutsResult = await _getLayouts(const NoParams());
    final layout = layoutsResult
        .getOrElse((_) => const [])
        .where((layout) => layout.id == layoutId)
        .firstOrNull;
    if (layout == null || layout.regions.isEmpty) return;

    // Ordem de leitura: linha por linha (de cima para baixo), da esquerda
    // para a direita dentro da linha.
    final settings = _settingsCubit.state.settings;
    final frames = <RegionFrame>[
      for (final region in layout.regions)
        regionFrameOnMonitor(
          region,
          monitor,
          gap: settings.windowGap,
          margin: settings.screenMargin,
        ),
    ]..sort((a, b) => a.y != b.y ? a.y.compareTo(b.y) : a.x.compareTo(b.x));

    final key = frames
        .map((f) => '${f.x},${f.y},${f.width},${f.height}')
        .join(';');
    if (key != _framesKey) {
      _framesKey = key;
      _lastIndexByWindow.clear();
    }

    // A memória só vale enquanto o centro da janela continua na região
    // lembrada — se o usuário a arrastou para outro lugar, recomeça.
    var remembered = _lastIndexByWindow[focused.id];
    if (remembered != null &&
        !_containsCenter(frames[remembered], _frameOf(focused))) {
      remembered = null;
    }

    final targetIndex = cycleTargetIndex(
      frames,
      _frameOf(focused),
      direction,
      currentIndex: remembered,
    );
    final target = frames[targetIndex];
    final result = await _windowsRepository.setWindowFrame(
      focused,
      x: target.x,
      y: target.y,
      width: target.width,
      height: target.height,
    );
    if (result.getOrElse((_) => false)) {
      _lastIndexByWindow[focused.id] = targetIndex;
    }
  }

  bool _containsCenter(
    RegionFrame frame,
    ({double x, double y, double width, double height}) windowFrame,
  ) {
    final centerX = windowFrame.x + windowFrame.width / 2;
    final centerY = windowFrame.y + windowFrame.height / 2;
    return centerX >= frame.x &&
        centerX <= frame.x + frame.width &&
        centerY >= frame.y &&
        centerY <= frame.y + frame.height;
  }

  ({double x, double y, double width, double height}) _frameOf(
    ManagedWindow window,
  ) => (x: window.x, y: window.y, width: window.width, height: window.height);
}
