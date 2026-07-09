import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/history_entry.dart';
import '../repositories/history_repository.dart';

/// Lista as entradas mais recentes do histórico.
@injectable
class GetHistory implements UseCase<List<HistoryEntry>, NoParams> {
  const GetHistory(this._repository);

  final HistoryRepository _repository;

  @override
  Future<Either<Failure, List<HistoryEntry>>> call(NoParams params) {
    return _repository.getEntries();
  }
}

class AddHistoryParams extends Equatable {
  const AddHistoryParams({
    required this.type,
    required this.title,
    this.subtitle,
  });

  final HistoryEntryType type;
  final String title;
  final String? subtitle;

  @override
  List<Object?> get props => [type, title, subtitle];
}

/// Registra um evento no histórico.
@injectable
class AddHistoryEntry implements UseCase<Unit, AddHistoryParams> {
  const AddHistoryEntry(this._repository);

  final HistoryRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(AddHistoryParams params) {
    return _repository.addEntry(
      HistoryEntry(
        type: params.type,
        title: params.title,
        subtitle: params.subtitle,
        createdAt: DateTime.now(),
      ),
    );
  }
}

/// Limpa o histórico.
@injectable
class ClearHistory implements UseCase<Unit, NoParams> {
  const ClearHistory(this._repository);

  final HistoryRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(NoParams params) {
    return _repository.clear();
  }
}
