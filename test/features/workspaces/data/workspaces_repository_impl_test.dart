import 'package:drift/native.dart';
import 'package:flowdesk/core/services/database/app_database.dart';
import 'package:flowdesk/features/layouts/data/datasources/layouts_local_datasource.dart';
import 'package:flowdesk/features/workspaces/data/datasources/preset_workspaces.dart';
import 'package:flowdesk/features/workspaces/data/datasources/workspaces_local_datasource.dart';
import 'package:flowdesk/features/workspaces/data/repositories/workspaces_repository_impl.dart';
import 'package:flowdesk/features/workspaces/domain/entities/workspace.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late WorkspacesRepositoryImpl repository;

  setUp(() async {
    db = AppDatabase.withExecutor(NativeDatabase.memory());
    // Semeia os layouts primeiro para o vínculo por nome funcionar.
    await LayoutsLocalDatasourceImpl(db).getLayouts();
    repository = WorkspacesRepositoryImpl(WorkspacesLocalDatasourceImpl(db));
  });

  tearDown(() async => db.close());

  test('semeia os workspaces de exemplo vinculados aos layouts', () async {
    final result = await repository.getWorkspaces();

    result.fold((f) => fail(f.message), (workspaces) {
      expect(workspaces.length, presetWorkspaces.length);

      final dev = workspaces.firstWhere((w) => w.name == 'Desenvolvimento');
      expect(dev.apps.length, 3);
      expect(dev.shortcut, '⌃1');
      expect(dev.layoutId, isNotNull);
      expect(dev.apps.first.bundleId, 'com.microsoft.VSCode');
    });

    // Não duplica na segunda chamada.
    final second = await repository.getWorkspaces();
    second.fold(
      (f) => fail(f.message),
      (workspaces) => expect(workspaces.length, presetWorkspaces.length),
    );
  });

  test('salva, atualiza e exclui workspace com apps', () async {
    const workspace = Workspace(
      name: 'Meu Workspace',
      apps: [
        WorkspaceApp(bundleId: 'com.x', appName: 'X'),
        WorkspaceApp(bundleId: 'com.y', appName: 'Y', sortOrder: 1),
      ],
    );

    final saved = (await repository.saveWorkspace(workspace)).getOrElse(
      (f) => fail(f.message),
    );
    expect(saved.id, greaterThan(0));
    expect(saved.apps.length, 2);

    final updated = (await repository.saveWorkspace(
      saved.copyWith(name: 'Renomeado', apps: [saved.apps.first]),
    )).getOrElse((f) => fail(f.message));
    expect(updated.name, 'Renomeado');
    expect(updated.apps.length, 1);

    await repository.deleteWorkspace(updated.id);
    final apps = await db.select(db.workspaceApps).get();
    expect(apps.any((a) => a.workspaceId == updated.id), isFalse);
  });

  test('setActive mantém um único workspace ativo', () async {
    final workspaces = (await repository.getWorkspaces()).getOrElse(
      (f) => fail(f.message),
    );

    await repository.setActive(workspaces[0].id);
    await repository.setActive(workspaces[1].id);

    final reloaded = (await repository.getWorkspaces()).getOrElse(
      (f) => fail(f.message),
    );
    final active = reloaded.where((w) => w.isActive).toList();
    expect(active.length, 1);
    expect(active.single.id, workspaces[1].id);
  });
}
