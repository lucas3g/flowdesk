import 'package:equatable/equatable.dart';

import '../../domain/entities/shortcut_binding.dart';

enum ShortcutsStatus { idle, ready, error }

/// Estado dos atalhos globais registrados.
class ShortcutsState extends Equatable {
  const ShortcutsState({
    this.status = ShortcutsStatus.idle,
    this.bindings = const [],
    this.errorMessage,
  });

  final ShortcutsStatus status;
  final List<ShortcutBinding> bindings;
  final String? errorMessage;

  List<ShortcutBinding> ofType(ShortcutActionType type) =>
      bindings.where((b) => b.type == type).toList(growable: false);

  ShortcutsState copyWith({
    ShortcutsStatus? status,
    List<ShortcutBinding>? bindings,
    String? errorMessage,
  }) {
    return ShortcutsState(
      status: status ?? this.status,
      bindings: bindings ?? this.bindings,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, bindings, errorMessage];
}
