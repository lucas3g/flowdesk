import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/monitor.dart';
import '../repositories/monitors_repository.dart';

/// Lista os monitores conectados no momento.
@injectable
class GetMonitors implements UseCase<List<Monitor>, NoParams> {
  const GetMonitors(this._repository);

  final MonitorsRepository _repository;

  @override
  Future<Either<Failure, List<Monitor>>> call(NoParams params) {
    return _repository.getMonitors();
  }
}
