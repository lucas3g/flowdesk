import 'package:bloc_test/bloc_test.dart';
import 'package:flowdesk/core/errors/failures.dart';
import 'package:flowdesk/core/usecases/usecase.dart';
import 'package:flowdesk/features/licensing/domain/entities/license.dart';
import 'package:flowdesk/features/licensing/domain/usecases/activate_license.dart';
import 'package:flowdesk/features/licensing/domain/usecases/deactivate_license.dart';
import 'package:flowdesk/features/licensing/domain/usecases/get_license.dart';
import 'package:flowdesk/features/licensing/domain/usecases/refresh_license.dart';
import 'package:flowdesk/features/licensing/presentation/cubits/license_cubit.dart';
import 'package:flowdesk/features/licensing/presentation/cubits/license_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class _MockGetLicense extends Mock implements GetLicense {}

class _MockActivateLicense extends Mock implements ActivateLicense {}

class _MockRefreshLicense extends Mock implements RefreshLicense {}

class _MockDeactivateLicense extends Mock implements DeactivateLicense {}

void main() {
  late _MockGetLicense getLicense;
  late _MockActivateLicense activateLicense;
  late _MockRefreshLicense refreshLicense;
  late _MockDeactivateLicense deactivateLicense;

  final premium = License(
    plan: LicensePlan.premium,
    key: 'FD-TESTE-1234',
    premiumUntil: DateTime(2030),
    lastValidatedAt: DateTime(2029, 12),
  );

  setUpAll(() {
    registerFallbackValue(const NoParams());
  });

  setUp(() {
    getLicense = _MockGetLicense();
    activateLicense = _MockActivateLicense();
    refreshLicense = _MockRefreshLicense();
    deactivateLicense = _MockDeactivateLicense();
  });

  LicenseCubit buildCubit() => LicenseCubit(
    getLicense,
    activateLicense,
    refreshLicense,
    deactivateLicense,
  );

  group('start', () {
    blocTest<LicenseCubit, LicenseState>(
      'carrega o plano grátis sem tentar revalidar',
      setUp: () {
        when(
          () => getLicense(any()),
        ).thenAnswer((_) async => right(License.free));
      },
      build: buildCubit,
      act: (cubit) => cubit.start(),
      expect: () => [
        const LicenseState(status: LicenseStatus.loading),
        const LicenseState(status: LicenseStatus.ready),
      ],
      verify: (_) => verifyNever(() => refreshLicense(any())),
    );

    blocTest<LicenseCubit, LicenseState>(
      'carrega premium do cache e não revalida validação recente',
      setUp: () {
        final recent = premium.copyWith(lastValidatedAt: DateTime.now());
        when(() => getLicense(any())).thenAnswer((_) async => right(recent));
      },
      build: buildCubit,
      act: (cubit) => cubit.start(),
      verify: (_) => verifyNever(() => refreshLicense(any())),
    );

    blocTest<LicenseCubit, LicenseState>(
      'revalida em segundo plano quando a validação está velha',
      setUp: () {
        final stale = premium.copyWith(
          lastValidatedAt: DateTime.now().subtract(const Duration(days: 10)),
        );
        when(() => getLicense(any())).thenAnswer((_) async => right(stale));
        when(
          () => refreshLicense(any()),
        ).thenAnswer((_) async => right(premium));
      },
      build: buildCubit,
      act: (cubit) => cubit.start(),
      verify: (_) => verify(() => refreshLicense(any())).called(1),
    );

    blocTest<LicenseCubit, LicenseState>(
      'falha de rede na revalidação não rebaixa o premium do cache',
      setUp: () {
        final stale = premium.copyWith(
          lastValidatedAt: DateTime.now().subtract(const Duration(days: 10)),
        );
        when(() => getLicense(any())).thenAnswer((_) async => right(stale));
        when(
          () => refreshLicense(any()),
        ).thenAnswer((_) async => left(const NetworkFailure('Sem conexão')));
      },
      build: buildCubit,
      act: (cubit) => cubit.start(),
      verify: (cubit) {
        expect(cubit.state.isPremium, isTrue);
        expect(cubit.state.status, LicenseStatus.ready);
      },
    );
  });

  group('activate', () {
    blocTest<LicenseCubit, LicenseState>(
      'emite activating e depois ready com o premium',
      setUp: () {
        when(
          () => activateLicense('FD-TESTE-1234'),
        ).thenAnswer((_) async => right(premium));
      },
      build: buildCubit,
      act: (cubit) => cubit.activate('FD-TESTE-1234'),
      expect: () => [
        const LicenseState(status: LicenseStatus.activating),
        LicenseState(status: LicenseStatus.ready, license: premium),
      ],
    );

    blocTest<LicenseCubit, LicenseState>(
      'chave inválida emite erro com a mensagem da falha',
      setUp: () {
        when(() => activateLicense('invalida')).thenAnswer(
          (_) async => left(
            const NetworkFailure('Chave não encontrada', statusCode: 404),
          ),
        );
      },
      build: buildCubit,
      act: (cubit) => cubit.activate('invalida'),
      expect: () => [
        const LicenseState(status: LicenseStatus.activating),
        const LicenseState(
          status: LicenseStatus.error,
          errorMessage: 'Chave não encontrada',
        ),
      ],
    );
  });

  group('deactivate', () {
    blocTest<LicenseCubit, LicenseState>(
      'volta ao plano grátis',
      seed: () => LicenseState(status: LicenseStatus.ready, license: premium),
      setUp: () {
        when(
          () => deactivateLicense(any()),
        ).thenAnswer((_) async => right(License.free));
      },
      build: buildCubit,
      act: (cubit) => cubit.deactivate(),
      expect: () => [const LicenseState(status: LicenseStatus.ready)],
    );
  });
}
