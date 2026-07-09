import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/ms_icon.dart';
import '../../../layouts/domain/entities/layout.dart';
import '../../../layouts/presentation/widgets/layout_preview.dart';
import '../cubits/layout_editor_state.dart';

/// Direção de um arrasto sobre a região: mover ou redimensionar por
/// borda/canto.
enum _DragMode {
  move,
  left,
  right,
  top,
  bottom,
  topLeft,
  topRight,
  bottomLeft,
  bottomRight;

  MouseCursor get cursor => switch (this) {
    _DragMode.move => SystemMouseCursors.move,
    _DragMode.left || _DragMode.right => SystemMouseCursors.resizeLeftRight,
    _DragMode.top || _DragMode.bottom => SystemMouseCursors.resizeUpDown,
    _DragMode.topLeft ||
    _DragMode.bottomRight => SystemMouseCursors.resizeUpLeftDownRight,
    _DragMode.topRight ||
    _DragMode.bottomLeft => SystemMouseCursors.resizeUpRightDownLeft,
  };

  bool get affectsLeft =>
      this == _DragMode.left ||
      this == _DragMode.topLeft ||
      this == _DragMode.bottomLeft;

  bool get affectsRight =>
      this == _DragMode.right ||
      this == _DragMode.topRight ||
      this == _DragMode.bottomRight;

  bool get affectsTop =>
      this == _DragMode.top ||
      this == _DragMode.topLeft ||
      this == _DragMode.topRight;

  bool get affectsBottom =>
      this == _DragMode.bottom ||
      this == _DragMode.bottomLeft ||
      this == _DragMode.bottomRight;
}

/// Canvas do editor: wallpaper, grade 20×12, regiões com mover/redimensionar
/// pelas bordas e cantos, e criação de região por arrasto em área vazia.
class EditorCanvas extends StatefulWidget {
  const EditorCanvas({
    super.key,
    required this.state,
    required this.onSelect,
    required this.onSetFrame,
    required this.onCreate,
    required this.onBringToFront,
    required this.onSendToBack,
  });

  final LayoutEditorState state;
  final ValueChanged<int?> onSelect;
  final void Function(int index, double x, double y, double width, double height)
  onSetFrame;
  final void Function(double x, double y, double width, double height) onCreate;
  final ValueChanged<int> onBringToFront;
  final ValueChanged<int> onSendToBack;

  /// Espessura (px) das zonas de redimensionamento nas bordas.
  static const double edgeGrip = 7;

  /// Lado (px) das zonas de canto.
  static const double cornerGrip = 12;

  @override
  State<EditorCanvas> createState() => _EditorCanvasState();
}

class _EditorCanvasState extends State<EditorCanvas> {
  /// Rascunho de criação por arrasto (em px do canvas).
  Offset? _draftStart;
  Rect? _draftRect;

  /// Estado do arrasto em andamento sobre uma região.
  LayoutRegion? _gestureOrigin;
  Offset _gestureDelta = Offset.zero;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AspectRatio(
      aspectRatio: 16 / 10,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);

          double toPercentX(double dx) => dx / size.width * 100;
          double toPercentY(double dy) => dy / size.height * 100;

          return ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Wallpaper + criação por arrasto em área vazia.
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapDown: (_) => widget.onSelect(null),
                  onPanStart: (details) {
                    _draftStart = details.localPosition;
                    setState(() => _draftRect = Rect.zero);
                  },
                  onPanUpdate: (details) {
                    final start = _draftStart;
                    if (start == null) return;
                    setState(
                      () => _draftRect = Rect.fromPoints(
                        start,
                        details.localPosition,
                      ),
                    );
                  },
                  onPanEnd: (_) {
                    final rect = _draftRect;
                    setState(() {
                      _draftStart = null;
                      _draftRect = null;
                    });
                    if (rect == null) return;
                    widget.onCreate(
                      toPercentX(rect.left),
                      toPercentY(rect.top),
                      toPercentX(rect.width),
                      toPercentY(rect.height),
                    );
                  },
                  child: const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF2C3550), Color(0xFF1A2138)],
                      ),
                    ),
                  ),
                ),
                if (widget.state.gridVisible)
                  IgnorePointer(
                    child: CustomPaint(
                      painter: _GridPainter(
                        columns: LayoutEditorState.gridColumns,
                        rows: LayoutEditorState.gridRows,
                        color: Colors.white.withValues(alpha: 0.07),
                      ),
                    ),
                  ),
                for (var i = 0; i < widget.state.layout.regions.length; i++)
                  _buildRegion(i, size, colors),
                if (_draftRect != null)
                  Positioned.fromRect(
                    rect: _draftRect!,
                    child: IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          color: colors.orange.withValues(alpha: 0.15),
                          border: Border.all(color: colors.orange),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRegion(int index, Size canvasSize, FlowDeskColors colors) {
    final region = widget.state.layout.regions[index];
    final selected = widget.state.selectedIndex == index;
    final color = colorFromHex(region.colorHex);

    return Positioned(
      left: region.x / 100 * canvasSize.width,
      top: region.y / 100 * canvasSize.height,
      width: region.width / 100 * canvasSize.width,
      height: region.height / 100 * canvasSize.height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Corpo da região: selecionar, mover e menu de contexto.
          Positioned.fill(
            child: _dragZone(
              index: index,
              mode: _DragMode.move,
              canvasSize: canvasSize,
              onSecondaryTapDown: (details) =>
                  _showRegionMenu(index, details.globalPosition),
              child: Container(
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: color, width: 1.5),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: color.withValues(alpha: 0.55),
                            blurRadius: 0,
                            spreadRadius: 2,
                          ),
                        ]
                      : const [],
                ),
                child: Stack(
                  children: [
                    Positioned(
                      left: 6,
                      top: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          region.hasApp
                              ? '${region.name} · ${region.appName}'
                              : region.name,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          ..._edgeZones(index, canvasSize),
          ..._cornerZones(index, canvasSize),
          // Pontos de canto visíveis quando selecionada (affordance).
          if (selected)
            for (final alignment in const [
              Alignment.topLeft,
              Alignment.topRight,
              Alignment.bottomLeft,
              Alignment.bottomRight,
            ])
              IgnorePointer(
                child: Align(
                  alignment: alignment,
                  child: Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(2),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }

  /// Zonas invisíveis nas quatro bordas.
  List<Widget> _edgeZones(int index, Size canvasSize) {
    const grip = EditorCanvas.edgeGrip;
    const corner = EditorCanvas.cornerGrip;
    return [
      Positioned(
        left: corner,
        right: corner,
        top: 0,
        height: grip,
        child: _dragZone(index: index, mode: _DragMode.top, canvasSize: canvasSize),
      ),
      Positioned(
        left: corner,
        right: corner,
        bottom: 0,
        height: grip,
        child: _dragZone(
          index: index,
          mode: _DragMode.bottom,
          canvasSize: canvasSize,
        ),
      ),
      Positioned(
        top: corner,
        bottom: corner,
        left: 0,
        width: grip,
        child: _dragZone(
          index: index,
          mode: _DragMode.left,
          canvasSize: canvasSize,
        ),
      ),
      Positioned(
        top: corner,
        bottom: corner,
        right: 0,
        width: grip,
        child: _dragZone(
          index: index,
          mode: _DragMode.right,
          canvasSize: canvasSize,
        ),
      ),
    ];
  }

  /// Zonas invisíveis nos quatro cantos.
  List<Widget> _cornerZones(int index, Size canvasSize) {
    const corner = EditorCanvas.cornerGrip;
    return [
      Positioned(
        left: 0,
        top: 0,
        width: corner,
        height: corner,
        child: _dragZone(
          index: index,
          mode: _DragMode.topLeft,
          canvasSize: canvasSize,
        ),
      ),
      Positioned(
        right: 0,
        top: 0,
        width: corner,
        height: corner,
        child: _dragZone(
          index: index,
          mode: _DragMode.topRight,
          canvasSize: canvasSize,
        ),
      ),
      Positioned(
        left: 0,
        bottom: 0,
        width: corner,
        height: corner,
        child: _dragZone(
          index: index,
          mode: _DragMode.bottomLeft,
          canvasSize: canvasSize,
        ),
      ),
      Positioned(
        right: 0,
        bottom: 0,
        width: corner,
        height: corner,
        child: _dragZone(
          index: index,
          mode: _DragMode.bottomRight,
          canvasSize: canvasSize,
        ),
      ),
    ];
  }

  /// Área arrastável com o cursor do modo; mover e redimensionar compartilham
  /// o mesmo ciclo de gesto.
  Widget _dragZone({
    required int index,
    required _DragMode mode,
    required Size canvasSize,
    GestureTapDownCallback? onSecondaryTapDown,
    Widget? child,
  }) {
    return MouseRegion(
      cursor: mode.cursor,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => widget.onSelect(index),
        onSecondaryTapDown: onSecondaryTapDown,
        onPanStart: (_) {
          _gestureOrigin = widget.state.layout.regions[index];
          _gestureDelta = Offset.zero;
          widget.onSelect(index);
        },
        onPanUpdate: (details) {
          final origin = _gestureOrigin;
          if (origin == null) return;
          _gestureDelta += details.delta;
          _applyDrag(index, mode, origin, canvasSize);
        },
        onPanEnd: (_) => _gestureOrigin = null,
        child: child ?? const SizedBox.expand(),
      ),
    );
  }

  /// Menu de contexto da região: alterar a ordem de empilhamento quando
  /// há regiões sobrepostas.
  Future<void> _showRegionMenu(int index, Offset globalPosition) async {
    widget.onSelect(index);
    final colors = context.colors;
    final overlay =
        Overlay.of(context).context.findRenderObject()! as RenderBox;

    final action = await showMenu<String>(
      context: context,
      position: RelativeRect.fromRect(
        globalPosition & Size.zero,
        Offset.zero & overlay.size,
      ),
      items: [
        PopupMenuItem(
          value: 'front',
          height: 36,
          child: Row(
            children: [
              MsIcon('flip_to_front', size: 15, color: colors.text2),
              const SizedBox(width: 8),
              const Text('Trazer para frente', style: TextStyle(fontSize: 12.5)),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'back',
          height: 36,
          child: Row(
            children: [
              MsIcon('flip_to_back', size: 15, color: colors.text2),
              const SizedBox(width: 8),
              const Text('Enviar para trás', style: TextStyle(fontSize: 12.5)),
            ],
          ),
        ),
      ],
    );

    switch (action) {
      case 'front':
        widget.onBringToFront(index);
      case 'back':
        widget.onSendToBack(index);
    }
  }

  /// Converte o delta acumulado em um novo frame conforme o modo.
  void _applyDrag(
    int index,
    _DragMode mode,
    LayoutRegion origin,
    Size canvasSize,
  ) {
    const minSize = LayoutEditorState.minRegionSize;
    final dx = _gestureDelta.dx / canvasSize.width * 100;
    final dy = _gestureDelta.dy / canvasSize.height * 100;

    if (mode == _DragMode.move) {
      widget.onSetFrame(
        index,
        origin.x + dx,
        origin.y + dy,
        origin.width,
        origin.height,
      );
      return;
    }

    var x = origin.x;
    var y = origin.y;
    var width = origin.width;
    var height = origin.height;

    if (mode.affectsLeft) {
      // Limita para a região não inverter nem ficar menor que o mínimo.
      final clampedDx = dx.clamp(-origin.x, origin.width - minSize);
      x = origin.x + clampedDx;
      width = origin.width - clampedDx;
    } else if (mode.affectsRight) {
      width = origin.width + dx;
    }

    if (mode.affectsTop) {
      final clampedDy = dy.clamp(-origin.y, origin.height - minSize);
      y = origin.y + clampedDy;
      height = origin.height - clampedDy;
    } else if (mode.affectsBottom) {
      height = origin.height + dy;
    }

    widget.onSetFrame(index, x, y, width, height);
  }
}

class _GridPainter extends CustomPainter {
  const _GridPainter({
    required this.columns,
    required this.rows,
    required this.color,
  });

  final int columns;
  final int rows;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    for (var c = 1; c < columns; c++) {
      final x = size.width * c / columns;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var r = 1; r < rows; r++) {
      final y = size.height * r / rows;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter oldDelegate) =>
      oldDelegate.columns != columns ||
      oldDelegate.rows != rows ||
      oldDelegate.color != color;
}
