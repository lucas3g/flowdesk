import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/layout.dart';
import '../repositories/layouts_repository.dart';

/// Lista todos os layouts salvos.
@injectable
class GetLayouts implements UseCase<List<Layout>, NoParams> {
  const GetLayouts(this._repository);

  final LayoutsRepository _repository;

  @override
  Future<Either<Failure, List<Layout>>> call(NoParams params) {
    return _repository.getLayouts();
  }
}
