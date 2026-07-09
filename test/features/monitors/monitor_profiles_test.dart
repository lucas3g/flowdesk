import 'package:drift/native.dart';
import 'package:flowdesk/core/services/database/app_database.dart';
import 'package:flowdesk/features/layouts/data/datasources/layouts_local_datasource.dart';
import 'package:flowdesk/features/monitors/data/datasources/monitor_profiles_local_datasource.dart';
import 'package:flowdesk/features/monitors/data/repositories/monitor_profiles_repository_impl.dart';
import 'package:flowdesk/features/monitors/domain/entities/monitor.dart';
import 'package:flowdesk/features/monitors/domain/entities/monitor_profile.dart';
import 'package:flutter_test/flutter_test.dart';

Monitor _monitor(String name, int px, {int id = 1}) => Monitor(
  id: id,
  name: name,
  x: 0,
  y: 0,
  width: 1000,
  height: 800,
  pixelWidth: px,
  pixelHeight: 1600,
  scale: 2,
  refreshRate: 60,
  isPrimary: id == 1,
  isBuiltIn: false,
);

void main() {
  group('monitorsFingerprint', () {
    test('é estável independentemente da ordem dos monitores', () {
      final a = [_monitor('MacBook', 3456), _monitor('Dell', 3840, id: 2)];
      final b = [_monitor('Dell', 3840, id: 2), _monitor('MacBook', 3456)];

      expect(monitorsFingerprint(a), monitorsFingerprint(b));
    });

    test('muda quando um monitor é adicionado ou trocado', () {
      final one = [_monitor('MacBook', 3456)];
      final two = [_monitor('MacBook', 3456), _monitor('Dell', 3840, id: 2)];
      final other = [_monitor('LG', 5120)];

      expect(monitorsFingerprint(one), isNot(monitorsFingerprint(two)));
      expect(monitorsFingerprint(one), isNot(monitorsFingerprint(other)));
    });
  });

  group('MonitorProfilesRepository', () {
    late AppDatabase db;
    late MonitorProfilesRepositoryImpl repository;
    late int layoutIdA;
    late int layoutIdB;

    setUp(() async {
      db = AppDatabase.withExecutor(NativeDatabase.memory());
      // Perfis referenciam layouts por FK: usa os presets semeados.
      final layouts = await LayoutsLocalDatasourceImpl(db).getLayouts();
      layoutIdA = layouts[0].id;
      layoutIdB = layouts[1].id;
      repository = MonitorProfilesRepositoryImpl(
        MonitorProfilesLocalDatasourceImpl(db),
      );
    });

    tearDown(() async => db.close());

    test('salvar com o mesmo fingerprint substitui o perfil', () async {
      final first = MonitorProfile(
        name: 'Escritório',
        fingerprint: 'Dell:3840x1600|MacBook:3456x1600',
        layoutId: layoutIdA,
      );

      await repository.saveProfile(first);
      await repository.saveProfile(
        first.copyWith(name: 'Escritório v2', layoutId: () => layoutIdB),
      );

      final profiles = (await repository.getProfiles()).getOrElse(
        (f) => fail(f.message),
      );
      expect(profiles.length, 1);
      expect(profiles.single.name, 'Escritório v2');
      expect(profiles.single.layoutId, layoutIdB);
    });

    test('exclui perfil', () async {
      final saved = (await repository.saveProfile(
        MonitorProfile(
          name: 'Notebook',
          fingerprint: 'MacBook:3456x1600',
          layoutId: layoutIdA,
        ),
      )).getOrElse((f) => fail(f.message));

      await repository.deleteProfile(saved.id);

      final profiles = (await repository.getProfiles()).getOrElse(
        (f) => fail(f.message),
      );
      expect(profiles, isEmpty);
    });
  });
}
