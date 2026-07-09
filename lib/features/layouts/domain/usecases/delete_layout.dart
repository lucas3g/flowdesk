import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/layouts_repository.dart';

/// Exclui um layout salvo pelo usuário.
@injectable
class DeleteLayout implements UseCase<Unit, int> {
  const DeleteLayout(this._repository);

  final LayoutsRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(int params) {
    return _repository.deleteLayout(params);
  }
}
