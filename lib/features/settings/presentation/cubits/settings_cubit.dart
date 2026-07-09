import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/usecases/apply_system_integration.dart';
import '../../domain/usecases/get_settings.dart';
import '../../domain/usecases/save_settings.dart';
import 'settings_state.dart';

/// Fonte única de verdade das preferências do app (incluindo o tema).
///
/// Preferências com efeito no sistema (login, Dock, menu bar) são aplicadas
/// via [ApplySystemIntegration] ao carregar e a cada alteração.
@lazySingleton
class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(this._getSettings, this._saveSettings, this._applyIntegration)
    : super(const SettingsState());

  final GetSettings _getSettings;
  final SaveSettings _saveSettings;
  final ApplySystemIntegration _applyIntegration;

  Future<void> load() async {
    final result = await _getSettings(const NoParams());
    result.fold(
      (failure) => emit(
        state.copyWith(status: SettingsStatus.error, errorMessage: failure.message),
      ),
      (settings) => emit(
        state.copyWith(status: SettingsStatus.ready, settings: settings),
      ),
    );
    await _applyIntegration(state.settings);
  }

  /// Aplica a mudança imediatamente na UI, persiste e sincroniza os
  /// efeitos no sistema.
  Future<void> _update(AppSettings Function(AppSettings) change) async {
    final previous = state.settings;
    final updated = change(previous);
    emit(state.copyWith(status: SettingsStatus.ready, settings: updated));

    final result = await _saveSettings(updated);
    result.fold(
      (failure) => emit(
        state.copyWith(status: SettingsStatus.error, errorMessage: failure.message),
      ),
      (_) {},
    );

    final integrationChanged =
        previous.launchAtLogin != updated.launchAtLogin ||
        previous.showInDock != updated.showInDock ||
        previous.showMenuBarIcon != updated.showMenuBarIcon;
    if (integrationChanged) {
      await _applyIntegration(updated);
    }
  }

  Future<void> setThemePreference(ThemePreference preference) =>
      _update((s) => s.copyWith(themePreference: preference));

  /// Alterna claro/escuro a partir do brilho efetivo atual (botão da titlebar).
  Future<void> toggleTheme(Brightness currentBrightness) => setThemePreference(
    currentBrightness == Brightness.dark
        ? ThemePreference.light
        : ThemePreference.dark,
  );

  Future<void> setLanguage(String language) =>
      _update((s) => s.copyWith(language: language));

  Future<void> setLaunchAtLogin(bool value) =>
      _update((s) => s.copyWith(launchAtLogin: value));

  Future<void> setShowMenuBarIcon(bool value) =>
      _update((s) => s.copyWith(showMenuBarIcon: value));

  Future<void> setShowInDock(bool value) =>
      _update((s) => s.copyWith(showInDock: value));

  Future<void> setMagneticSnap(bool value) =>
      _update((s) => s.copyWith(magneticSnap: value));

  Future<void> setAnimateTransitions(bool value) =>
      _update((s) => s.copyWith(animateTransitions: value));

  Future<void> setAnimationDurationMs(int value) =>
      _update((s) => s.copyWith(animationDurationMs: value));

  Future<void> setWindowGap(double value) =>
      _update((s) => s.copyWith(windowGap: value));

  Future<void> setScreenMargin(double value) =>
      _update((s) => s.copyWith(screenMargin: value));

  Future<void> setBarTransparency(bool value) =>
      _update((s) => s.copyWith(barTransparency: value));

  Future<void> setUserName(String name) =>
      _update((s) => s.copyWith(userName: name.trim()));

  /// Marca o onboarding como concluído, gravando o nome informado.
  Future<void> completeOnboarding({String? userName}) => _update(
    (s) => s.copyWith(
      onboardingDone: true,
      userName: userName != null ? userName.trim() : s.userName,
    ),
  );
}
