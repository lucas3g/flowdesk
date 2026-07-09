import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/app_settings.dart';

enum SettingsStatus { loading, ready, error }

/// Estado global de preferências. Enquanto carrega, expõe os valores padrão
/// para a UI não depender de nulos.
class SettingsState extends Equatable {
  const SettingsState({
    this.status = SettingsStatus.loading,
    this.settings = const AppSettings(),
    this.errorMessage,
  });

  final SettingsStatus status;
  final AppSettings settings;
  final String? errorMessage;

  /// Modo de tema do Flutter derivado da preferência persistida.
  ThemeMode get themeMode => switch (settings.themePreference) {
    ThemePreference.system => ThemeMode.system,
    ThemePreference.light => ThemeMode.light,
    ThemePreference.dark => ThemeMode.dark,
  };

  SettingsState copyWith({
    SettingsStatus? status,
    AppSettings? settings,
    String? errorMessage,
  }) {
    return SettingsState(
      status: status ?? this.status,
      settings: settings ?? this.settings,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, settings, errorMessage];
}
