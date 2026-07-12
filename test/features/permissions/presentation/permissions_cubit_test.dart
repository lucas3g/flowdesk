import 'package:bloc_test/bloc_test.dart';
import 'package:flowdesk/core/errors/failures.dart';
import 'package:flowdesk/core/usecases/usecase.dart';
import 'package:flowdesk/features/permissions/domain/entities/permissions_status.dart';
import 'package:flowdesk/features/permissions/domain/usecases/get_permissions_status.dart';
import 'package:flowdesk/features/permissions/domain/usecases/open_permission_settings.dart';
import 'package:flowdesk/features/permissions/domain/usecases/request_accessibility.dart';
import 'package:flowdesk/features/permissions/presentation/cubits/permissions_cubit.dart';
import 'package:flowdesk/features/permissions/presentation/cubits/permissions_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class _MockGetStatus extends Mock implements GetPermissionsStatus {}

class _MockRequestAccessibility extends Mock implements RequestAccessibility {}

class _MockOpenSettings extends Mock implements OpenPermissionSettings {}

void main() {
  late _MockGetStatus getStatus;
  late _MockRequestAccessibility requestAccessibility;
  late _MockOpenSettings openSettings;

  const granted = PermissionsStatus(accessibility: true, screenRecording: true);
  const missing = PermissionsStatus(
    accessibility: false,
    screenRecording: false,
  );

  setUpAll(() {
    registerFallbackValue(const NoParams());
    registerFallbackValue(PermissionType.accessibility);
  });

  setUp(() {
    getStatus = _MockGetStatus();
    requestAccessibility = _MockRequestAccessibility();
    openSettings = _MockOpenSettings();
  });

  PermissionsCubit buildCubit() =>
      PermissionsCubit(getStatus, requestAccessibility, openSettings);

  blocTest<PermissionsCubit, PermissionsState>(
    'check emite checked com as permissões atuais',
    setUp: () =>
        when(() => getStatus(any())).thenAnswer((_) async => right(granted)),
    build: buildCubit,
    act: (cubit) => cubit.check(),
    expect: () => [
      const PermissionsState(
        status: PermissionsCheckStatus.checked,
        permissions: granted,
      ),
    ],
  );

  blocTest<PermissionsCubit, PermissionsState>(
    'check emite error quando o canal falha',
    setUp: () => when(
      () => getStatus(any()),
    ).thenAnswer((_) async => left(const PlatformFailure('sem canal'))),
    build: buildCubit,
    act: (cubit) => cubit.check(),
    expect: () => [
      isA<PermissionsState>().having(
        (s) => s.status,
        'status',
        PermissionsCheckStatus.error,
      ),
    ],
  );

  test('needsAccessibility só é verdadeiro após verificação concluída', () {
    const initial = PermissionsState();
    expect(initial.needsAccessibility, isFalse);

    const checkedMissing = PermissionsState(
      status: PermissionsCheckStatus.checked,
      permissions: missing,
    );
    expect(checkedMissing.needsAccessibility, isTrue);

    const checkedGranted = PermissionsState(
      status: PermissionsCheckStatus.checked,
      permissions: granted,
    );
    expect(checkedGranted.needsAccessibility, isFalse);
  });

  blocTest<PermissionsCubit, PermissionsState>(
    'startMonitoring não agenda polling quando tudo concedido',
    setUp: () =>
        when(() => getStatus(any())).thenAnswer((_) async => right(granted)),
    build: buildCubit,
    act: (cubit) => cubit.startMonitoring(),
    wait: const Duration(milliseconds: 100),
    verify: (_) => verify(() => getStatus(any())).called(1),
  );

  blocTest<PermissionsCubit, PermissionsState>(
    'requestAccessibility chama o use case do prompt',
    setUp: () {
      when(() => getStatus(any())).thenAnswer((_) async => right(granted));
      when(
        () => requestAccessibility(any()),
      ).thenAnswer((_) async => right(false));
    },
    build: buildCubit,
    seed: () => const PermissionsState(
      status: PermissionsCheckStatus.checked,
      permissions: granted,
    ),
    act: (cubit) => cubit.requestAccessibility(),
    verify: (_) => verify(() => requestAccessibility(any())).called(1),
  );
}
