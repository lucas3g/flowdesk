import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/usecases/usecase.dart';
import '../../../monitors/domain/entities/monitor.dart';
import '../../domain/usecases/applied_layouts_usecases.dart';

/// Layout aplicado em cada monitor (chave estável → id do layout),
/// persistido entre sessões. Alimenta as zonas de encaixe ao arrastar
/// ([SnapRegionsService]) e o ciclo de regiões por atalho.
@lazySingleton
class AppliedLayoutsCubit extends Cubit<Map<String, int>> {
  AppliedLayoutsCubit(
    this._getAppliedLayouts,
    this._setAppliedLayout,
    this._removeAppliedLayout,
  ) : super(const {});

  final GetAppliedLayouts _getAppliedLayouts;
  final SetAppliedLayout _setAppliedLayout;
  final RemoveAppliedLayout _removeAppliedLayout;

  Future<void> load() async {
    final result = await _getAppliedLayouts(const NoParams());
    result.fold((_) {}, emit);
  }

  /// Registra (ou substitui) o layout aplicado no monitor.
  Future<void> set(String monitorKey, int layoutId) async {
    final result = await _setAppliedLayout(
      SetAppliedLayoutParams(monitorKey: monitorKey, layoutId: layoutId),
    );
    result.fold((_) {}, (_) => emit({...state, monitorKey: layoutId}));
  }

  /// Remove o layout aplicado do monitor.
  Future<void> remove(String monitorKey) async {
    final result = await _removeAppliedLayout(monitorKey);
    result.fold((_) {}, (_) => emit({...state}..remove(monitorKey)));
  }

  /// Id do layout aplicado no monitor, se houver.
  int? layoutIdFor(Monitor monitor) => state[monitorKey(monitor)];
}
