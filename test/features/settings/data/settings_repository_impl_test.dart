import 'package:drift/native.dart';
import 'package:flowdesk/core/services/database/app_database.dart';
import 'package:flowdesk/features/settings/data/datasources/settings_local_datasource.dart';
import 'package:flowdesk/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:flowdesk/features/settings/domain/entities/app_settings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late SettingsRepositoryImpl repository;

  setUp(() {
    db = AppDatabase.withExecutor(NativeDatabase.memory());
    repository = SettingsRepositoryImpl(SettingsLocalDatasourceImpl(db));
  });

  tearDown(() async => db.close());

  test('retorna os padrões na primeira execução', () async {
    final result = await repository.getSettings();

    expect(result.isRight(), isTrue);
    result.fold((_) => fail('não deveria falhar'), (settings) {
      expect(settings.themePreference, ThemePreference.system);
      expect(settings.windowGap, 8);
      // No banco, o onboarding começa pendente (diferente do default da
      // entidade, pensado para testes/telas sem persistência).
      expect(settings.onboardingDone, isFalse);
    });
  });

  test('completar o onboarding persiste a flag', () async {
    final initial = (await repository.getSettings()).getOrElse(
      (f) => fail(f.message),
    );
    await repository.saveSettings(initial.copyWith(onboardingDone: true));

    final reloaded = (await repository.getSettings()).getOrElse(
      (f) => fail(f.message),
    );
    expect(reloaded.onboardingDone, isTrue);
  });

  test('persiste e recarrega as preferências alteradas', () async {
    const updated = AppSettings(
      themePreference: ThemePreference.dark,
      language: 'en_US',
      launchAtLogin: true,
      windowGap: 16,
      magneticSnap: false,
      snapToLayoutRegions: true,
      snapExcludedApps: [
        SnapExcludedApp(bundleId: 'com.apple.mail', appName: 'Mail'),
        SnapExcludedApp(
          bundleId: 'com.google.chrome',
          appName: 'Chrome',
          windowId: 4321,
          windowTitle: 'YouTube',
        ),
      ],
    );

    final saveResult = await repository.saveSettings(updated);
    expect(saveResult.isRight(), isTrue);

    final loaded = await repository.getSettings();
    loaded.fold(
      (_) => fail('não deveria falhar'),
      (settings) => expect(settings, updated),
    );
  });

  test('salvar duas vezes mantém uma única linha (upsert)', () async {
    await repository.saveSettings(
      const AppSettings(themePreference: ThemePreference.light),
    );
    await repository.saveSettings(
      const AppSettings(themePreference: ThemePreference.dark),
    );

    final rows = await db.select(db.settingsTable).get();
    expect(rows.length, 1);

    final loaded = await repository.getSettings();
    loaded.fold(
      (_) => fail('não deveria falhar'),
      (settings) => expect(settings.themePreference, ThemePreference.dark),
    );
  });
}
