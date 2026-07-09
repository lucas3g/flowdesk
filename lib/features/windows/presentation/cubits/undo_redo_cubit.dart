import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/managed_window.dart';
import '../../domain/usecases/get_windows.dart';
import '../../domain/usecases/move_resize_window.dart';

/// Posição/tamanho de uma janela em um instante.
class WindowSnapshot extends Equatable {
  const WindowSnapshot({
    required this.window,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  factory WindowSnapshot.of(ManagedWindow window) => WindowSnapshot(
    window: window,
    x: window.x,
    y: window.y,
    width: window.width,
    height: window.height,
  );

  final ManagedWindow window;
  final double x;
  final double y;
  final double width;
  final double height;

  @override
  List<Object?> get props => [window.id, x, y, width, height];
}

/// Estado das pilhas de desfazer/refazer.
class UndoRedoState extends Equatable {
  const UndoRedoState({this.undoDepth = 0, this.redoDepth = 0});

  final int undoDepth;
  final int redoDepth;

  bool get canUndo => undoDepth > 0;
  bool get canRedo => redoDepth > 0;

  @override
  List<Object?> get props => [undoDepth, redoDepth];
}

/// Desfaz/refaz movimentações de janelas feitas pelo FlowDesk.
///
/// Antes de cada operação (aplicar layout, centralizar, maximizar), os
/// frames atuais das janelas afetadas são empilhados via [pushSnapshot].
@lazySingleton
class UndoRedoCubit extends Cubit<UndoRedoState> {
  UndoRedoCubit(this._getWindows, this._moveResize)
    : super(const UndoRedoState());

  final GetWindows _getWindows;
  final MoveResizeWindow _moveResize;

  static const int _maxDepth = 30;

  final List<List<WindowSnapshot>> _undoStack = [];
  final List<List<WindowSnapshot>> _redoStack = [];

  /// Registra os frames atuais das janelas antes de uma movimentação.
  void pushSnapshot(List<ManagedWindow> windows) {
    if (windows.isEmpty) return;
    _undoStack.add([for (final window in windows) WindowSnapshot.of(window)]);
    if (_undoStack.length > _maxDepth) _undoStack.removeAt(0);
    _redoStack.clear();
    _emitDepths();
  }

  Future<void> undo() => _restoreTop(from: _undoStack, to: _redoStack);

  Future<void> redo() => _restoreTop(from: _redoStack, to: _undoStack);

  Future<void> _restoreTop({
    required List<List<WindowSnapshot>> from,
    required List<List<WindowSnapshot>> to,
  }) async {
    if (from.isEmpty) return;
    final group = from.removeLast();

    // Guarda os frames atuais para permitir a operação inversa.
    final current = (await _getWindows(const NoParams())).getOrElse(
      (_) => const [],
    );
    final inverse = <WindowSnapshot>[];
    for (final snapshot in group) {
      final live = current
          .where((window) => window.id == snapshot.window.id)
          .firstOrNull;
      if (live != null) inverse.add(WindowSnapshot.of(live));
    }
    if (inverse.isNotEmpty) to.add(inverse);

    for (final snapshot in group) {
      await _moveResize(
        MoveResizeParams(
          window: snapshot.window,
          x: snapshot.x,
          y: snapshot.y,
          width: snapshot.width,
          height: snapshot.height,
        ),
      );
    }
    _emitDepths();
  }

  void _emitDepths() {
    emit(
      UndoRedoState(
        undoDepth: _undoStack.length,
        redoDepth: _redoStack.length,
      ),
    );
  }
}
