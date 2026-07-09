import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/layouts_repository.dart';

class ToggleFavoriteParams extends Equatable {
  const ToggleFavoriteParams({required this.layoutId, required this.isFavorite});

  final int layoutId;
  final bool isFavorite;

  @override
  List<Object?> get props => [layoutId, isFavorite];
}

/// Marca/desmarca um layout como favorito.
@injectable
class ToggleFavoriteLayout implements UseCase<Unit, ToggleFavoriteParams> {
  const ToggleFavoriteLayout(this._repository);

  final LayoutsRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(ToggleFavoriteParams params) {
    return _repository.setFavorite(params.layoutId, params.isFavorite);
  }
}
