import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/usecases/usecase.dart';
import '../../../layouts/presentation/cubits/layouts_cubit.dart';
import '../../../workspaces/presentation/cubits/workspaces_cubit.dart';
import '../../domain/entities/monitor_profile.dart';
import '../../domain/usecases/monitor_profiles_usecases.dart';
import 'monitors_cubit.dart';
import 'monitors_state.dart';

/// Estado dos perfis por configuração de monitores.
class MonitorProfilesState extends Equatable {
  const MonitorProfilesState({
    this.profiles = const [],
    this.currentFingerprint = '',
    this.feedback,
  });

  final List<MonitorProfile> profiles;

  /// Fingerprint da combinação de monitores conectada agora.
  final String currentFingerprint;
  final String? feedback;

  /// Perfil correspondente à configuração atual, se houver.
  MonitorProfile? get currentProfile {
    for (final profile in profiles) {
      if (profile.fingerprint == currentFingerprint) return profile;
    }
    return null;
  }

  MonitorProfilesState copyWith({
    List<MonitorProfile>? profiles,
    String? currentFingerprint,
    String? feedback,
  }) {
    return MonitorProfilesState(
      profiles: profiles ?? this.profiles,
      currentFingerprint: currentFingerprint ?? this.currentFingerprint,
      feedback: feedback,
    );
  }

  @override
  List<Object?> get props => [profiles, currentFingerprint, feedback];
}

/// Gerencia perfis por combinação de monitores e aplica automaticamente
/// o workspace/layout do perfil quando a configuração de telas muda.
@lazySingleton
class MonitorProfilesCubit extends Cubit<MonitorProfilesState> {
  MonitorProfilesCubit(
    this._getProfiles,
    this._saveProfile,
    this._deleteProfile,
    this._monitorsCubit,
    this._workspacesCubit,
    this._layoutsCubit,
  ) : super(const MonitorProfilesState());

  final GetMonitorProfiles _getProfiles;
  final SaveMonitorProfile _saveProfile;
  final DeleteMonitorProfile _deleteProfile;
  final MonitorsCubit _monitorsCubit;
  final WorkspacesCubit _workspacesCubit;
  final LayoutsCubit _layoutsCubit;

  StreamSubscription<MonitorsState>? _subscription;

  /// Última configuração para a qual o perfil já foi aplicado (evita
  /// reaplicar em eventos repetidos).
  String? _lastAppliedFingerprint;

  Future<void> start() async {
    await load();
    _onMonitorsChanged(_monitorsCubit.state, autoApply: false);
    _subscription ??= _monitorsCubit.stream.listen(_onMonitorsChanged);
  }

  Future<void> load() async {
    final result = await _getProfiles(const NoParams());
    result.fold(
      (failure) => emit(state.copyWith(feedback: failure.message)),
      (profiles) => emit(state.copyWith(profiles: profiles)),
    );
  }

  /// Salva o perfil da configuração de monitores atual.
  Future<void> saveForCurrentSetup({
    required String name,
    int? workspaceId,
    int? layoutId,
    bool autoApply = true,
  }) async {
    final result = await _saveProfile(
      MonitorProfile(
        name: name,
        fingerprint: state.currentFingerprint,
        workspaceId: workspaceId,
        layoutId: layoutId,
        autoApply: autoApply,
      ),
    );
    await result.fold(
      (failure) async => emit(state.copyWith(feedback: failure.message)),
      (profile) async {
        await load();
        emit(state.copyWith(feedback: "Perfil '${profile.name}' salvo."));
      },
    );
  }

  Future<void> delete(MonitorProfile profile) async {
    await _deleteProfile(profile.id);
    await load();
  }

  void clearFeedback() {
    if (state.feedback != null) emit(state.copyWith());
  }

  void _onMonitorsChanged(
    MonitorsState monitorsState, {
    bool autoApply = true,
  }) {
    if (monitorsState.monitors.isEmpty) return;
    final fingerprint = monitorsFingerprint(monitorsState.monitors);
    if (fingerprint == state.currentFingerprint) return;

    emit(state.copyWith(currentFingerprint: fingerprint));
    if (autoApply) _autoApplyProfile(fingerprint);
  }

  Future<void> _autoApplyProfile(String fingerprint) async {
    if (_lastAppliedFingerprint == fingerprint) return;

    final profile = state.currentProfile;
    if (profile == null || !profile.autoApply) return;
    _lastAppliedFingerprint = fingerprint;

    if (profile.workspaceId != null) {
      for (final workspace in _workspacesCubit.state.workspaces) {
        if (workspace.id == profile.workspaceId) {
          await _workspacesCubit.apply(workspace);
          emit(
            state.copyWith(
              feedback: "Perfil '${profile.name}' aplicado automaticamente.",
            ),
          );
          return;
        }
      }
    }
    if (profile.layoutId != null) {
      for (final layout in _layoutsCubit.state.layouts) {
        if (layout.id == profile.layoutId) {
          await _layoutsCubit.apply(layout);
          emit(
            state.copyWith(
              feedback: "Perfil '${profile.name}' aplicado automaticamente.",
            ),
          );
          return;
        }
      }
    }
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
