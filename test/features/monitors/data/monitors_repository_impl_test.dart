import 'package:flowdesk/core/errors/exceptions.dart';
import 'package:flowdesk/core/errors/failures.dart';
import 'package:flowdesk/features/monitors/data/datasources/monitors_platform_datasource.dart';
import 'package:flowdesk/features/monitors/data/repositories/monitors_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockDatasource extends Mock implements MonitorsPlatformDatasource {}

void main() {
  late _MockDatasource datasource;
  late MonitorsRepositoryImpl repository;

  setUp(() {
    datasource = _MockDatasource();
    repository = MonitorsRepositoryImpl(datasource);
  });

  test('getMonitors converte o payload em entidades', () async {
    when(() => datasource.getMonitors()).thenAnswer(
      (_) async => <Object?>[
        <Object?, Object?>{'id': 1, 'name': 'Dell', 'isPrimary': true},
      ],
    );

    final result = await repository.getMonitors();

    result.fold((_) => fail('não deveria falhar'), (monitors) {
      expect(monitors.length, 1);
      expect(monitors.single.name, 'Dell');
    });
  });

  test('getMonitors mapeia erro nativo em PlatformFailure', () async {
    when(
      () => datasource.getMonitors(),
    ).thenThrow(const PlatformDatasourceException('canal indisponível'));

    final result = await repository.getMonitors();

    result.fold(
      (failure) => expect(failure, isA<PlatformFailure>()),
      (_) => fail('deveria falhar'),
    );
  });

  test('watchMonitors emite listas convertidas a cada evento', () async {
    when(() => datasource.watchMonitors()).thenAnswer(
      (_) => Stream<Object?>.fromIterable([
        <Object?>[
          <Object?, Object?>{'id': 1, 'name': 'A'},
        ],
        <Object?>[
          <Object?, Object?>{'id': 1, 'name': 'A'},
          <Object?, Object?>{'id': 2, 'name': 'B'},
        ],
      ]),
    );

    final events = await repository.watchMonitors().toList();

    expect(events.length, 2);
    events.last.fold(
      (_) => fail('não deveria falhar'),
      (monitors) => expect(monitors.length, 2),
    );
  });

  test('watchMonitors converte erro do stream em PlatformFailure', () async {
    when(() => datasource.watchMonitors()).thenAnswer(
      (_) => Stream<Object?>.error(
        const PlatformDatasourceException('stream caiu'),
      ),
    );

    final events = await repository.watchMonitors().toList();

    expect(events.length, 1);
    events.single.fold(
      (failure) => expect(failure, isA<PlatformFailure>()),
      (_) => fail('deveria falhar'),
    );
  });
}
