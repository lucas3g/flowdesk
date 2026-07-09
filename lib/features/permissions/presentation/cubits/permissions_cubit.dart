import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/permissions_status.dart';
import '../../domain/usecases/get_permissions_status.dart';
import '../../domain/usecases/open_permission_settings.dart';
import '../../domain/usecases/request_accessibility.dart';
import 'permissions_state.dart';

/// Observa as permissões do macOS e guia o usuário até as Ajustes do Sistema.
///
/// Enquanto a Acessibilidade não for concedida, re-verifica periodicamente —
/// o macOS não notifica o app quando o usuário concede a permissão.
@lazySingleton
class PermissionsCubit extends Cubit<PermissionsState> {
  PermissionsCubit(
    this._getStatus,
    this._requestAccessibility,
    this._openSettings,
  ) : super(const PermissionsState());

  final GetPermissionsStatus _getStatus;
  final RequestAccessibility _requestAccessibility;
  final OpenPermissionSettings _openSettings;

  Timer? _pollTimer;

  static const Duration _pollInterval = Duration(seconds: 3);

  /// Verifica uma única vez.
  Future<void> check() async {
    final result = await _getStatus(const NoParams());
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: PermissionsCheckStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (permissions) => emit(
        state.copyWith(
          status: PermissionsCheckStatus.checked,
          permissions: permissions,
        ),
      ),
    );
  }

  /// Verifica agora e continua re-verificando até a Acessibilidade
  /// ser concedida.
  Future<void> startMonitoring() async {
    await check();
    _schedulePollingIfNeeded();
  }

  /// Exibe o prompt do sistema e abre as Ajustes na seção de Acessibilidade.
  Future<void> requestAccessibility() async {
    await _requestAccessibility(const NoParams());
    _schedulePollingIfNeeded();
  }

  Future<void> openSettings(PermissionType type) async {
    await _openSettings(type);
    _schedulePollingIfNeeded();
  }

  void _schedulePollingIfNeeded() {
    if (state.permissions.accessibility) {
      _pollTimer?.cancel();
      _pollTimer = null;
      return;
    }
    _pollTimer ??= Timer.periodic(_pollInterval, (_) async {
      await check();
      if (state.permissions.accessibility) {
        _pollTimer?.cancel();
        _pollTimer = null;
      }
    });
  }

  @override
  Future<void> close() {
    _pollTimer?.cancel();
    return super.close();
  }
}
