import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/layout.dart';
import '../repositories/layouts_repository.dart';

/// Insere ou atualiza um layout com suas regiões.
@injectable
class SaveLayout implements UseCase<Layout, Layout> {
  const SaveLayout(this._repository);

  final LayoutsRepository _repository;

  @override
  Future<Either<Failure, Layout>> call(Layout params) {
    if (params.name.trim().isEmpty) {
      return Future.value(
        left(const ValidationFailure('O layout precisa de um nome.')),
      );
    }
    if (params.regions.isEmpty) {
      return Future.value(
        left(const ValidationFailure('O layout precisa de ao menos uma região.')),
      );
    }
    return _repository.saveLayout(params);
  }
}
