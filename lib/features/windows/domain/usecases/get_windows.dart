import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/managed_window.dart';
import '../repositories/windows_repository.dart';

/// Lista as janelas visíveis de outros aplicativos.
@injectable
class GetWindows implements UseCase<List<ManagedWindow>, NoParams> {
  const GetWindows(this._repository);

  final WindowsRepository _repository;

  @override
  Future<Either<Failure, List<ManagedWindow>>> call(NoParams params) {
    return _repository.getWindows();
  }
}
