import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/activate_license.dart';
import '../../domain/usecases/deactivate_license.dart';
import '../../domain/usecases/get_license.dart';
import '../../domain/usecases/refresh_license.dart';
import 'license_state.dart';

/// Fonte única de verdade do plano do usuário (grátis/premium).
///
/// No boot, carrega o cache local imediatamente (sem depender de rede) e
/// revalida com o servidor em segundo plano quando a última validação
/// está velha ou o premium entrou na tolerância offline.
@lazySingleton
class LicenseCubit extends Cubit<LicenseState> {
  LicenseCubit(
    this._getLicense,
    this._activateLicense,
    this._refreshLicense,
    this._deactivateLicense,
  ) : super(const LicenseState());

  final GetLicense _getLicense;
  final ActivateLicense _activateLicense;
  final RefreshLicense _refreshLicense;
  final DeactivateLicense _deactivateLicense;

  Future<void> start() async {
    emit(state.copyWith(status: LicenseStatus.loading));

    final result = await _getLicense(const NoParams());
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: LicenseStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (license) =>
          emit(state.copyWith(status: LicenseStatus.ready, license: license)),
    );

    if (_needsRevalidation()) await _silentRefresh();
  }

  Future<void> activate(String key) async {
    emit(state.copyWith(status: LicenseStatus.activating));

    final result = await _activateLicense(key);
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: LicenseStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (license) =>
          emit(state.copyWith(status: LicenseStatus.ready, license: license)),
    );
  }

  Future<void> deactivate() async {
    final result = await _deactivateLicense(const NoParams());
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: LicenseStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (license) =>
          emit(state.copyWith(status: LicenseStatus.ready, license: license)),
    );
  }

  /// Revalidação pendente: nunca validou, validação velha ou premium
  /// sobrevivendo só pela tolerância offline.
  bool _needsRevalidation() {
    final license = state.license;
    if (license.key.isEmpty) return false;
    if (license.inGracePeriod) return true;

    final lastValidatedAt = license.lastValidatedAt;
    if (lastValidatedAt == null) return true;
    return DateTime.now().difference(lastValidatedAt) >
        AppConstants.licenseRevalidationInterval;
  }

  /// Revalida sem rebaixar o estado em falha de rede — o cache local e a
  /// tolerância offline continuam valendo.
  Future<void> _silentRefresh() async {
    final result = await _refreshLicense(const NoParams());
    result.fold(
      (_) {},
      (license) =>
          emit(state.copyWith(status: LicenseStatus.ready, license: license)),
    );
  }
}
