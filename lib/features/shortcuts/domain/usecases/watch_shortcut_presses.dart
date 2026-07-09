import 'package:injectable/injectable.dart';

import '../repositories/shortcuts_repository.dart';

/// Observa os acionamentos de atalhos globais.
@injectable
class WatchShortcutPresses {
  const WatchShortcutPresses(this._repository);

  final ShortcutsRepository _repository;

  Stream<int> call() => _repository.pressed();
}
