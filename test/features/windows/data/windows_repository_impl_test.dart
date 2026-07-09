import 'package:flowdesk/core/errors/exceptions.dart';
import 'package:flowdesk/core/errors/failures.dart';
import 'package:flowdesk/features/windows/data/datasources/windows_platform_datasource.dart';
import 'package:flowdesk/features/windows/data/repositories/windows_repository_impl.dart';
import 'package:flowdesk/features/windows/domain/entities/managed_window.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockDatasource extends Mock implements WindowsPlatformDatasource {}

const _window = ManagedWindow(
  id: 1,
  pid: 100,
  appName: 'Safari',
  bundleId: 'com.apple.Safari',
  title: 'Página',
  x: 0,
  y: 0,
  width: 800,
  height: 600,
  monitorId: 1,
  isFocused: false,
);

void main() {
  late _MockDatasource datasource;
  late WindowsRepositoryImpl repository;

  setUp(() {
    datasource = _MockDatasource();
    repository = WindowsRepositoryImpl(datasource);
  });

  test('getWindows converte o payload em entidades', () async {
    when(() => datasource.getWindows()).thenAnswer(
      (_) async => <Object?>[
        <Object?, Object?>{'id': 1, 'appName': 'Safari'},
      ],
    );

    final result = await repository.getWindows();

    result.fold(
      (_) => fail('não deveria falhar'),
      (windows) => expect(windows.single.appName, 'Safari'),
    );
  });

  test('mapeia accessibility_denied em PermissionFailure', () async {
    when(
      () => datasource.setWindowFrame(
        windowId: any(named: 'windowId'),
        pid: any(named: 'pid'),
        x: any(named: 'x'),
        y: any(named: 'y'),
        width: any(named: 'width'),
        height: any(named: 'height'),
      ),
    ).thenThrow(
      const PlatformDatasourceException(
        'sem permissão',
        code: 'accessibility_denied',
      ),
    );

    final result = await repository.setWindowFrame(
      _window,
      x: 0,
      y: 0,
      width: 100,
      height: 100,
    );

    result.fold(
      (failure) {
        expect(failure, isA<PermissionFailure>());
        expect((failure as PermissionFailure).permission, 'accessibility');
      },
      (_) => fail('deveria falhar'),
    );
  });

  test('focusWindow repassa id e pid ao canal', () async {
    when(
      () => datasource.focusWindow(
        windowId: any(named: 'windowId'),
        pid: any(named: 'pid'),
      ),
    ).thenAnswer((_) async => true);

    final result = await repository.focusWindow(_window);

    expect(result.getOrElse((_) => false), isTrue);
    verify(() => datasource.focusWindow(windowId: 1, pid: 100)).called(1);
  });
}
