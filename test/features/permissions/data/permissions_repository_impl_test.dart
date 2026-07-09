import 'package:flowdesk/core/errors/exceptions.dart';
import 'package:flowdesk/core/errors/failures.dart';
import 'package:flowdesk/features/permissions/data/datasources/permissions_platform_datasource.dart';
import 'package:flowdesk/features/permissions/data/repositories/permissions_repository_impl.dart';
import 'package:flowdesk/features/permissions/domain/entities/permissions_status.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockDatasource extends Mock implements PermissionsPlatformDatasource {}

void main() {
  late _MockDatasource datasource;
  late PermissionsRepositoryImpl repository;

  setUp(() {
    datasource = _MockDatasource();
    repository = PermissionsRepositoryImpl(datasource);
  });

  group('getStatus', () {
    test('converte o payload do canal em entidade', () async {
      when(() => datasource.getStatus()).thenAnswer(
        (_) async => {'accessibility': true, 'screenRecording': false},
      );

      final result = await repository.getStatus();

      result.fold((_) => fail('não deveria falhar'), (status) {
        expect(
          status,
          const PermissionsStatus(accessibility: true, screenRecording: false),
        );
        expect(status.isOperational, isTrue);
      });
    });

    test('mapeia erro nativo em PlatformFailure', () async {
      when(() => datasource.getStatus()).thenThrow(
        const PlatformDatasourceException('canal indisponível', code: 'err'),
      );

      final result = await repository.getStatus();

      result.fold(
        (failure) => expect(failure, isA<PlatformFailure>()),
        (_) => fail('deveria falhar'),
      );
    });
  });

  test('openSystemSettings envia o nome da seção correta', () async {
    when(() => datasource.openSystemSettings(any())).thenAnswer((_) async {});

    await repository.openSystemSettings(PermissionType.screenRecording);

    verify(() => datasource.openSystemSettings('screenRecording')).called(1);
  });

  test('requestAccessibility repassa o resultado do sistema', () async {
    when(() => datasource.requestAccessibility()).thenAnswer((_) async => true);

    final result = await repository.requestAccessibility();

    expect(result.getOrElse((_) => false), isTrue);
  });
}
