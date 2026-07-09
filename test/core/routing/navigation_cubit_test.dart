import 'package:bloc_test/bloc_test.dart';
import 'package:flowdesk/core/routing/app_screen.dart';
import 'package:flowdesk/core/routing/navigation_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NavigationCubit', () {
    test('inicia no Dashboard', () {
      expect(NavigationCubit().state, AppScreen.dashboard);
    });

    blocTest<NavigationCubit, AppScreen>(
      'emite a nova tela ao navegar',
      build: NavigationCubit.new,
      act: (cubit) => cubit.navigate(AppScreen.monitors),
      expect: () => [AppScreen.monitors],
    );

    blocTest<NavigationCubit, AppScreen>(
      'não emite quando a tela é a mesma',
      build: NavigationCubit.new,
      act: (cubit) => cubit.navigate(AppScreen.dashboard),
      expect: () => const <AppScreen>[],
    );
  });

  group('AppScreen', () {
    test('Dashboard não possui título de breadcrumb', () {
      expect(AppScreen.dashboard.breadcrumbTitle, isNull);
      expect(AppScreen.settings.breadcrumbTitle, 'Configurações');
    });

    test('todas as telas pertencem a uma seção da sidebar', () {
      for (final screen in AppScreen.values) {
        expect(SidebarSection.values, contains(screen.section));
      }
    });
  });
}
