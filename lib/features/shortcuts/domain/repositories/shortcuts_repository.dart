import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/shortcut_binding.dart';

/// Contrato de registro de hotkeys globais no macOS.
abstract interface class ShortcutsRepository {
  /// Substitui todos os atalhos registrados pela lista informada.
  Future<Either<Failure, Unit>> registerAll(List<ShortcutBinding> bindings);

  /// Ids dos atalhos acionados (mesmo id passado em [registerAll]).
  Stream<int> pressed();
}
