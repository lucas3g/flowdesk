import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/managed_window.dart';
import '../../domain/repositories/windows_repository.dart';
import '../datasources/windows_platform_datasource.dart';
import '../models/managed_window_model.dart';

@LazySingleton(as: WindowsRepository)
class WindowsRepositoryImpl implements WindowsRepository {
  const WindowsRepositoryImpl(this._datasource);

  final WindowsPlatformDatasource _datasource;

  /// A camada nativa devolve `accessibility_denied` quando a permissão
  /// de Acessibilidade não foi concedida.
  static const String _accessibilityDeniedCode = 'accessibility_denied';

  @override
  Future<Either<Failure, List<ManagedWindow>>> getWindows() async {
    try {
      final payload = await _datasource.getWindows();
      return right(ManagedWindowModel.listFromChannel(payload));
    } on PlatformDatasourceException catch (e) {
      return left(_mapPlatformException(e));
    } catch (e) {
      return left(UnexpectedFailure('$e'));
    }
  }

  @override
  Future<Either<Failure, bool>> setWindowFrame(
    ManagedWindow window, {
    required double x,
    required double y,
    required double width,
    required double height,
    bool settle = true,
  }) async {
    try {
      final success = await _datasource.setWindowFrame(
        windowId: window.id,
        pid: window.pid,
        x: x,
        y: y,
        width: width,
        height: height,
        settle: settle,
      );
      return right(success);
    } on PlatformDatasourceException catch (e) {
      return left(_mapPlatformException(e));
    } catch (e) {
      return left(UnexpectedFailure('$e'));
    }
  }

  @override
  Future<Either<Failure, bool>> focusWindow(ManagedWindow window) async {
    try {
      final success = await _datasource.focusWindow(
        windowId: window.id,
        pid: window.pid,
      );
      return right(success);
    } on PlatformDatasourceException catch (e) {
      return left(_mapPlatformException(e));
    } catch (e) {
      return left(UnexpectedFailure('$e'));
    }
  }

  Failure _mapPlatformException(PlatformDatasourceException e) {
    if (e.code == _accessibilityDeniedCode) {
      return PermissionFailure(e.message, permission: 'accessibility');
    }
    return PlatformFailure(e.message, code: e.code);
  }
}
