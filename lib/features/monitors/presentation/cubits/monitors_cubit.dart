import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/monitor.dart';
import '../../domain/usecases/get_monitors.dart';
import '../../domain/usecases/watch_monitors.dart';
import 'monitors_state.dart';

/// Mantém a lista de monitores sincronizada com o sistema: carrega o estado
/// atual e assina o stream nativo de mudanças (conectar/remover telas).
@lazySingleton
class MonitorsCubit extends Cubit<MonitorsState> {
  MonitorsCubit(this._getMonitors, this._watchMonitors)
    : super(const MonitorsState());

  final GetMonitors _getMonitors;
  final WatchMonitors _watchMonitors;

  StreamSubscription<Either<Failure, List<Monitor>>>? _subscription;

  /// Carrega a lista e passa a observar mudanças de configuração.
  Future<void> start() async {
    await refresh();
    _subscription ??= _watchMonitors(const NoParams()).listen(_applyResult);
  }

  /// Recarrega sob demanda (botão "Detectar novamente").
  Future<void> refresh() async {
    _applyResult(await _getMonitors(const NoParams()));
  }

  /// Seleciona/desseleciona um monitor na visualização.
  void select(int monitorId) {
    emit(
      state.copyWith(
        selectedId: () => state.selectedId == monitorId ? null : monitorId,
      ),
    );
  }

  void _applyResult(Either<Failure, List<Monitor>> result) {
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: MonitorsStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (monitors) {
        final selectionStillValid = monitors.any(
          (monitor) => monitor.id == state.selectedId,
        );
        emit(
          state.copyWith(
            status: MonitorsStatus.ready,
            monitors: monitors,
            // Limpa a seleção se o monitor selecionado foi desconectado.
            selectedId: selectionStillValid ? null : () => null,
          ),
        );
      },
    );
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
