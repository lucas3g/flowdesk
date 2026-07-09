import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/managed_window.dart';

/// Contrato de acesso e manipulação de janelas de outros apps.
abstract interface class WindowsRepository {
  Future<Either<Failure, List<ManagedWindow>>> getWindows();

  /// Move/redimensiona a janela (coordenadas CG globais).
  Future<Either<Failure, bool>> setWindowFrame(
    ManagedWindow window, {
    required double x,
    required double y,
    required double width,
    required double height,
  });

  /// Traz a janela para frente e ativa o app dono.
  Future<Either<Failure, bool>> focusWindow(ManagedWindow window);
}
