import 'package:injectable/injectable.dart';

import '../../features/layouts/domain/entities/layout.dart';
import '../../features/layouts/domain/usecases/apply_layout.dart';
import '../../features/monitors/presentation/cubits/monitors_cubit.dart';
import '../../features/settings/presentation/cubits/settings_cubit.dart';
import '../../features/windows/domain/entities/managed_window.dart';
import '../../features/windows/domain/repositories/windows_repository.dart';
import 'region_cycle_service.dart' show regionIndexOfFrame;

/// Direção do encaixe pelo teclado (⌃⌥ + setas).
enum SnapDirection { left, right, up, down }

/// Encaixe rápido da janela em foco pelo teclado, estilo Windows, acionado
/// pelos atalhos globais ⌃⌥←/→/↑/↓ enquanto a preferência está ligada.
///
/// As posições são regiões sintéticas em percentuais da área útil do monitor,
/// convertidas em frame por [regionFrameOnMonitor] (respeita gap/margem). Cada
/// direção progride ao ser repetida: metade → quadrante superior → inferior.
/// Convive com o ciclo de regiões (⌘⌥←/→) — são combinações diferentes.
@lazySingleton
class WindowSnapService {
  WindowSnapService(
    this._settingsCubit,
    this._monitorsCubit,
    this._windowsRepository,
  );

  final SettingsCubit _settingsCubit;
  final MonitorsCubit _monitorsCubit;
  final WindowsRepository _windowsRepository;

  /// Evita reentrância enquanto um movimento ainda está em andamento.
  bool _busy = false;

  /// Última posição para onde cada janela foi enviada, por direção
  /// (`"windowId:direction"` → índice) — permite continuar avançando na
  /// progressão mesmo quando o app ajusta o próprio frame.
  final Map<String, int> _lastIndexByWindow = {};

  Future<void> snap(SnapDirection direction) async {
    if (_busy) return;
    _busy = true;
    try {
      await _snap(direction);
    } finally {
      _busy = false;
    }
  }

  Future<void> _snap(SnapDirection direction) async {
    if (!_settingsCubit.state.settings.keyboardSnap) return;

    final windowsResult = await _windowsRepository.getWindows();
    final focused = windowsResult
        .getOrElse((_) => const [])
        .where((window) => window.isFocused && !window.isMinimized)
        .firstOrNull;
    if (focused == null) return;

    final monitor = _monitorsCubit.state.monitors
        .where((monitor) => monitor.id == focused.monitorId)
        .firstOrNull;
    if (monitor == null) return;

    final settings = _settingsCubit.state.settings;
    final frames = <RegionFrame>[
      for (final region in _regionsFor(direction))
        regionFrameOnMonitor(
          region,
          monitor,
          gap: settings.windowGap,
          margin: settings.screenMargin,
        ),
    ];

    final windowFrame = _frameOf(focused);
    final targetIndex = _nextIndex(direction, focused.id, frames, windowFrame);
    final target = frames[targetIndex];
    final result = await _windowsRepository.setWindowFrame(
      focused,
      x: target.x,
      y: target.y,
      width: target.width,
      height: target.height,
      // Movimento interativo: aplica uma vez, sem reaplicações tardias que
      // puxariam a janela de volta ao encaixar de novo em seguida.
      settle: false,
    );
    if (result.getOrElse((_) => false)) {
      _lastIndexByWindow['${focused.id}:${direction.index}'] = targetIndex;
    }
  }

  /// Índice da próxima posição na progressão da direção: parte da posição
  /// atual (memória validada ou frame que coincide) e avança uma, dando a
  /// volta nas pontas; fora de qualquer posição, começa pela primeira.
  int _nextIndex(
    SnapDirection direction,
    int windowId,
    List<RegionFrame> frames,
    RegionFrame windowFrame,
  ) {
    var remembered = _lastIndexByWindow['$windowId:${direction.index}'];
    // A memória só vale enquanto o centro da janela continua na posição
    // lembrada — se o usuário a arrastou/redimensionou, recomeça.
    if (remembered != null &&
        (remembered >= frames.length ||
            !_containsCenter(frames[remembered], windowFrame))) {
      remembered = null;
    }

    final current = remembered ?? regionIndexOfFrame(frames, windowFrame);
    if (current == null) return 0;
    return (current + 1) % frames.length;
  }

  /// Regiões sintéticas (percentuais) da progressão de cada direção.
  List<LayoutRegion> _regionsFor(SnapDirection direction) {
    switch (direction) {
      case SnapDirection.left:
        return const [
          LayoutRegion(name: 'left-half', x: 0, y: 0, width: 50, height: 100),
          LayoutRegion(name: 'top-left', x: 0, y: 0, width: 50, height: 50),
          LayoutRegion(name: 'bottom-left', x: 0, y: 50, width: 50, height: 50),
        ];
      case SnapDirection.right:
        return const [
          LayoutRegion(name: 'right-half', x: 50, y: 0, width: 50, height: 100),
          LayoutRegion(name: 'top-right', x: 50, y: 0, width: 50, height: 50),
          LayoutRegion(
            name: 'bottom-right',
            x: 50,
            y: 50,
            width: 50,
            height: 50,
          ),
        ];
      case SnapDirection.up:
        return const [
          LayoutRegion(name: 'maximize', x: 0, y: 0, width: 100, height: 100),
        ];
      case SnapDirection.down:
        return const [
          LayoutRegion(name: 'center', x: 20, y: 15, width: 60, height: 70),
        ];
    }
  }

  bool _containsCenter(RegionFrame frame, RegionFrame windowFrame) {
    final centerX = windowFrame.x + windowFrame.width / 2;
    final centerY = windowFrame.y + windowFrame.height / 2;
    return centerX >= frame.x &&
        centerX <= frame.x + frame.width &&
        centerY >= frame.y &&
        centerY <= frame.y + frame.height;
  }

  RegionFrame _frameOf(ManagedWindow window) =>
      (x: window.x, y: window.y, width: window.width, height: window.height);
}
