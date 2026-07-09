import 'package:flowdesk/core/errors/failures.dart';
import 'package:flowdesk/core/platform/platform_event_channel.dart';
import 'package:flowdesk/features/history/domain/usecases/history_usecases.dart';
import 'package:flowdesk/features/settings/domain/entities/app_settings.dart';
import 'package:flowdesk/features/settings/domain/usecases/apply_system_integration.dart';
import 'package:flowdesk/features/windows/domain/entities/managed_window.dart';
import 'package:flowdesk/features/windows/presentation/cubits/undo_redo_cubit.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

/// EventChannel falso alimentado por um Stream arbitrário.
class FakeEventChannel extends PlatformEventChannel {
  FakeEventChannel(this._stream) : super('fake');

  final Stream<Object?> _stream;

  @override
  Stream<T> receive<T>() => _stream.cast<T>();
}

/// Integração de sistema inerte para testes que não a exercitam.
class FakeApplySystemIntegration extends Fake
    implements ApplySystemIntegration {
  @override
  Future<Either<Failure, Unit>> call(AppSettings params) async => right(unit);
}

/// Registro de histórico inerte para testes que não o exercitam.
class FakeAddHistoryEntry extends Fake implements AddHistoryEntry {
  @override
  Future<Either<Failure, Unit>> call(AddHistoryParams params) async =>
      right(unit);
}

/// Cubit de undo/redo mockado (o snapshot é verificado apenas quando
/// o teste o exercita explicitamente).
class MockUndoRedoCubit extends Mock implements UndoRedoCubit {
  MockUndoRedoCubit() {
    registerFallbackValue(<ManagedWindow>[]);
    when(() => pushSnapshot(any())).thenReturn(null);
  }
}
