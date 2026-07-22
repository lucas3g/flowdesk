import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/managed_window.dart';

/// Contrato de acesso e manipulação de janelas de outros apps.
abstract interface class WindowsRepository {
  Future<Either<Failure, List<ManagedWindow>>> getWindows();

  /// Move/redimensiona a janela (coordenadas CG globais).
  ///
  /// [settle] (padrão true) reaplica o frame por ~1,2s para segurar janelas
  /// que voltam sozinhas (regras/layouts em janelas recém-criadas). Movimentos
  /// interativos passam false para aplicar só uma vez, sem reaplicações
  /// tardias que atrapalhariam o próximo movimento.
  Future<Either<Failure, bool>> setWindowFrame(
    ManagedWindow window, {
    required double x,
    required double y,
    required double width,
    required double height,
    bool settle = true,
  });

  /// Traz a janela para frente e ativa o app dono.
  Future<Either<Failure, bool>> focusWindow(ManagedWindow window);
}
