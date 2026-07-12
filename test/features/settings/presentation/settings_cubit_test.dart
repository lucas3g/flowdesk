import 'package:bloc_test/bloc_test.dart';
import 'package:flowdesk/core/errors/failures.dart';
import 'package:flowdesk/core/usecases/usecase.dart';
import 'package:flowdesk/features/settings/domain/entities/app_settings.dart';
import 'package:flowdesk/features/settings/domain/usecases/apply_system_integration.dart';
import 'package:flowdesk/features/settings/domain/usecases/get_settings.dart';
import 'package:flowdesk/features/settings/domain/usecases/save_settings.dart';
import 'package:flowdesk/features/settings/presentation/cubits/settings_cubit.dart';
import 'package:flowdesk/features/settings/presentation/cubits/settings_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class _MockGetSettings extends Mock implements GetSettings {}

class _MockSaveSettings extends Mock implements SaveSettings {}

class _MockApplySystemIntegration extends Mock
    implements ApplySystemIntegration {}

void main() {
  late _MockGetSettings getSettings;
  late _MockSaveSettings saveSettings;
  late _MockApplySystemIntegration applyIntegration;

  setUpAll(() {
    registerFallbackValue(const NoParams());
    registerFallbackValue(const AppSettings());
  });

  setUp(() {
    getSettings = _MockGetSettings();
    saveSettings = _MockSaveSettings();
    applyIntegration = _MockApplySystemIntegration();
    when(() => saveSettings(any())).thenAnswer((_) async => right(unit));
    when(() => applyIntegration(any())).thenAnswer((_) async => right(unit));
  });

  SettingsCubit buildCubit() =>
      SettingsCubit(getSettings, saveSettings, applyIntegration);

  group('load', () {
    blocTest<SettingsCubit, SettingsState>(
      'emite ready com as preferências carregadas',
      setUp: () => when(() => getSettings(any())).thenAnswer(
        (_) async =>
            right(const AppSettings(themePreference: ThemePreference.dark)),
      ),
      build: buildCubit,
      act: (cubit) => cubit.load(),
      expect: () => [
        const SettingsState(
          status: SettingsStatus.ready,
          settings: AppSettings(themePreference: ThemePreference.dark),
        ),
      ],
    );

    blocTest<SettingsCubit, SettingsState>(
      'emite error quando o carregamento falha',
      setUp: () => when(
        () => getSettings(any()),
      ).thenAnswer((_) async => left(const DatabaseFailure('erro'))),
      build: buildCubit,
      act: (cubit) => cubit.load(),
      expect: () => [
        isA<SettingsState>()
            .having((s) => s.status, 'status', SettingsStatus.error)
            .having((s) => s.errorMessage, 'errorMessage', 'erro'),
      ],
    );
  });

  group('atualizações', () {
    blocTest<SettingsCubit, SettingsState>(
      'atualiza o tema e persiste',
      build: buildCubit,
      act: (cubit) => cubit.setThemePreference(ThemePreference.dark),
      expect: () => [
        isA<SettingsState>().having(
          (s) => s.settings.themePreference,
          'themePreference',
          ThemePreference.dark,
        ),
      ],
      verify: (_) => verify(() => saveSettings(any())).called(1),
    );

    blocTest<SettingsCubit, SettingsState>(
      'toggleTheme alterna de escuro para claro',
      build: buildCubit,
      act: (cubit) => cubit.toggleTheme(Brightness.dark),
      expect: () => [
        isA<SettingsState>().having(
          (s) => s.themeMode,
          'themeMode',
          ThemeMode.light,
        ),
      ],
    );

    blocTest<SettingsCubit, SettingsState>(
      'aplica a integração de sistema ao alterar Dock/menu bar/login',
      build: buildCubit,
      act: (cubit) => cubit.setShowInDock(false),
      verify: (_) {
        final applied =
            verify(() => applyIntegration(captureAny())).captured.single
                as AppSettings;
        expect(applied.showInDock, isFalse);
      },
    );

    blocTest<SettingsCubit, SettingsState>(
      'não reaplica integração para preferências sem efeito no sistema',
      build: buildCubit,
      act: (cubit) => cubit.setWindowGap(12),
      verify: (_) => verifyNever(() => applyIntegration(any())),
    );

    blocTest<SettingsCubit, SettingsState>(
      'setSnapToLayoutRegions persiste a preferência',
      build: buildCubit,
      act: (cubit) => cubit.setSnapToLayoutRegions(true),
      expect: () => [
        isA<SettingsState>().having(
          (s) => s.settings.snapToLayoutRegions,
          'snapToLayoutRegions',
          isTrue,
        ),
      ],
      verify: (_) => verify(() => saveSettings(any())).called(1),
    );

    blocTest<SettingsCubit, SettingsState>(
      'setSnapExcludedApps persiste e reaplica a integração',
      build: buildCubit,
      act: (cubit) => cubit.setSnapExcludedApps(const [
        SnapExcludedApp(bundleId: 'com.apple.mail', appName: 'Mail'),
      ]),
      expect: () => [
        isA<SettingsState>().having(
          (s) => s.settings.snapExcludedApps,
          'snapExcludedApps',
          const [SnapExcludedApp(bundleId: 'com.apple.mail', appName: 'Mail')],
        ),
      ],
      verify: (_) {
        verify(() => saveSettings(any())).called(1);
        final applied =
            verify(() => applyIntegration(captureAny())).captured.single
                as AppSettings;
        expect(applied.snapExcludedApps.single.bundleId, 'com.apple.mail');
      },
    );

    blocTest<SettingsCubit, SettingsState>(
      'emite error quando a persistência falha',
      setUp: () => when(
        () => saveSettings(any()),
      ).thenAnswer((_) async => left(const DatabaseFailure('sem espaço'))),
      build: buildCubit,
      act: (cubit) => cubit.setWindowGap(16),
      expect: () => [
        isA<SettingsState>().having(
          (s) => s.settings.windowGap,
          'windowGap',
          16,
        ),
        isA<SettingsState>().having(
          (s) => s.status,
          'status',
          SettingsStatus.error,
        ),
      ],
    );
  });
}
