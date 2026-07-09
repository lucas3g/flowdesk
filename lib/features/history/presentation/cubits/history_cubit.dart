import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/history_entry.dart';
import '../../domain/usecases/history_usecases.dart';

/// Estado do histórico de atividades.
class HistoryState extends Equatable {
  const HistoryState({this.entries = const [], this.isLoading = true});

  final List<HistoryEntry> entries;
  final bool isLoading;

  HistoryState copyWith({List<HistoryEntry>? entries, bool? isLoading}) {
    return HistoryState(
      entries: entries ?? this.entries,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [entries, isLoading];
}

/// Carrega e limpa o histórico exibido nas telas Histórico e Dashboard.
@lazySingleton
class HistoryCubit extends Cubit<HistoryState> {
  HistoryCubit(this._getHistory, this._clearHistory)
    : super(const HistoryState());

  final GetHistory _getHistory;
  final ClearHistory _clearHistory;

  Future<void> load() async {
    final result = await _getHistory(const NoParams());
    result.fold(
      (_) => emit(state.copyWith(isLoading: false)),
      (entries) => emit(HistoryState(entries: entries, isLoading: false)),
    );
  }

  Future<void> clear() async {
    await _clearHistory(const NoParams());
    await load();
  }
}
