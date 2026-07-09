import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/monitor.dart';
import '../repositories/monitors_repository.dart';

/// Observa mudanças na configuração de monitores (conectar/remover telas).
@injectable
class WatchMonitors implements StreamUseCase<List<Monitor>, NoParams> {
  const WatchMonitors(this._repository);

  final MonitorsRepository _repository;

  @override
  Stream<Either<Failure, List<Monitor>>> call(NoParams params) {
    return _repository.watchMonitors();
  }
}
