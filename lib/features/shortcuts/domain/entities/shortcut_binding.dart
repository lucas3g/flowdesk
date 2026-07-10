import 'package:equatable/equatable.dart';

import 'hotkey_combo.dart';

/// Ação executada por um atalho global.
enum ShortcutActionType {
  applyLayout,
  applyWorkspace,

  /// Move a janela focada para a região anterior/seguinte do layout aplicado.
  cycleRegionPrev,
  cycleRegionNext,
}

/// Vínculo entre um combo global e uma ação do FlowDesk.
class ShortcutBinding extends Equatable {
  const ShortcutBinding({
    required this.id,
    required this.combo,
    required this.type,
    required this.targetId,
    required this.description,
  });

  /// Identificador enviado ao Carbon e devolvido no evento de acionamento.
  final int id;
  final HotkeyCombo combo;
  final ShortcutActionType type;

  /// Id do layout/workspace alvo.
  final int targetId;

  /// Nome exibido na tela de Atalhos (ex.: nome do layout).
  final String description;

  @override
  List<Object?> get props => [id, combo, type, targetId, description];
}
