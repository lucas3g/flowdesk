import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/shortcut_binding.dart';
import '../../domain/repositories/shortcuts_repository.dart';
import '../datasources/shortcuts_platform_datasource.dart';

@LazySingleton(as: ShortcutsRepository)
class ShortcutsRepositoryImpl implements ShortcutsRepository {
  const ShortcutsRepositoryImpl(this._datasource);

  final ShortcutsPlatformDatasource _datasource;

  @override
  Future<Either<Failure, Unit>> registerAll(
    List<ShortcutBinding> bindings,
  ) async {
    try {
      await _datasource.registerShortcuts([
        for (final binding in bindings)
          {
            'id': binding.id,
            // macOS (Carbon):
            'keyCode': binding.combo.keyCode,
            'modifiers': binding.combo.modifiers,
            // Neutro (Windows converte para VK/MOD):
            'key': binding.combo.key,
            'cmd': binding.combo.hasCmd,
            'shift': binding.combo.hasShift,
            'alt': binding.combo.hasOption,
            'ctrl': binding.combo.hasControl,
            'win': binding.combo.hasWin,
          },
      ]);
      return right(unit);
    } on PlatformDatasourceException catch (e) {
      return left(PlatformFailure(e.message, code: e.code));
    } catch (e) {
      return left(UnexpectedFailure('$e'));
    }
  }

  @override
  Stream<int> pressed() => _datasource.pressed();
}
