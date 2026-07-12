import 'package:drift/native.dart';
import 'package:flowdesk/core/services/database/app_database.dart';
import 'package:flowdesk/features/layouts/data/datasources/layouts_local_datasource.dart';
import 'package:flowdesk/features/layouts/data/datasources/preset_layouts.dart';
import 'package:flowdesk/features/layouts/data/repositories/layouts_repository_impl.dart';
import 'package:flowdesk/features/layouts/domain/entities/layout.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late LayoutsRepositoryImpl repository;

  setUp(() {
    db = AppDatabase.withExecutor(NativeDatabase.memory());
    repository = LayoutsRepositoryImpl(LayoutsLocalDatasourceImpl(db));
  });

  tearDown(() async => db.close());

  test('semeia os presets na primeira execução', () async {
    final result = await repository.getLayouts();

    result.fold((_) => fail('não deveria falhar'), (layouts) {
      expect(layouts.length, presetLayouts.length);
      expect(layouts.every((l) => l.isPreset), isTrue);
      final codigoTerminal = layouts.firstWhere(
        (l) => l.name == 'Código & Terminal',
      );
      expect(codigoTerminal.regions.length, 3);
      expect(codigoTerminal.shortcut, '⌥1');
      expect(codigoTerminal.regions.first.name, 'Editor');
    });

    // Segunda chamada não duplica os seeds.
    final second = await repository.getLayouts();
    second.fold(
      (_) => fail('não deveria falhar'),
      (layouts) => expect(layouts.length, presetLayouts.length),
    );
  });

  test('salva, atualiza e exclui um layout do usuário', () async {
    const custom = Layout(
      name: 'Meu Layout',
      category: LayoutCategory.dev,
      regions: [
        LayoutRegion(name: 'A', x: 0, y: 0, width: 50, height: 100),
        LayoutRegion(name: 'B', x: 50, y: 0, width: 50, height: 100),
      ],
    );

    final saved = (await repository.saveLayout(
      custom,
    )).getOrElse((f) => fail(f.message));
    expect(saved.id, greaterThan(0));
    expect(saved.regions.length, 2);

    final updated = (await repository.saveLayout(
      saved.copyWith(
        name: 'Renomeado',
        regions: [
          const LayoutRegion(
            name: 'Única',
            x: 0,
            y: 0,
            width: 100,
            height: 100,
          ),
        ],
      ),
    )).getOrElse((f) => fail(f.message));
    expect(updated.name, 'Renomeado');
    expect(updated.regions.length, 1);

    await repository.deleteLayout(updated.id);
    final after = (await repository.getLayouts()).getOrElse(
      (f) => fail(f.message),
    );
    expect(after.any((l) => l.id == updated.id), isFalse);
    // Regiões excluídas em cascata.
    final orphanRegions = await db.select(db.layoutRegions).get();
    expect(orphanRegions.any((r) => r.layoutId == updated.id), isFalse);
  });

  test('persiste a associação de app da região', () async {
    const layout = Layout(
      name: 'Com App',
      regions: [
        LayoutRegion(
          name: 'Editor',
          x: 0,
          y: 0,
          width: 100,
          height: 100,
          appBundleId: 'com.microsoft.VSCode',
          appName: 'VS Code',
        ),
      ],
    );

    final saved = (await repository.saveLayout(
      layout,
    )).getOrElse((f) => fail(f.message));

    final reloaded = (await repository.getLayouts()).getOrElse(
      (f) => fail(f.message),
    );
    final region = reloaded.firstWhere((l) => l.id == saved.id).regions.single;
    expect(region.appBundleId, 'com.microsoft.VSCode');
    expect(region.appName, 'VS Code');
  });

  test('setFavorite alterna o favorito', () async {
    final layouts = (await repository.getLayouts()).getOrElse(
      (f) => fail(f.message),
    );
    final first = layouts.first;

    await repository.setFavorite(first.id, true);

    final reloaded = (await repository.getLayouts()).getOrElse(
      (f) => fail(f.message),
    );
    expect(reloaded.firstWhere((l) => l.id == first.id).isFavorite, isTrue);
  });

  test('registra, substitui e remove o layout aplicado por monitor', () async {
    final layouts = (await repository.getLayouts()).getOrElse(
      (f) => fail(f.message),
    );
    final first = layouts[0];
    final second = layouts[1];

    await repository.setAppliedLayout('Principal:4000x2400', first.id);
    await repository.setAppliedLayout('Externo:1920x1080', second.id);

    var applied = (await repository.getAppliedLayouts()).getOrElse(
      (f) => fail(f.message),
    );
    expect(applied, {
      'Principal:4000x2400': first.id,
      'Externo:1920x1080': second.id,
    });

    // Aplicar outro layout no mesmo monitor substitui (upsert).
    await repository.setAppliedLayout('Principal:4000x2400', second.id);
    applied = (await repository.getAppliedLayouts()).getOrElse(
      (f) => fail(f.message),
    );
    expect(applied['Principal:4000x2400'], second.id);

    await repository.removeAppliedLayout('Externo:1920x1080');
    applied = (await repository.getAppliedLayouts()).getOrElse(
      (f) => fail(f.message),
    );
    expect(applied.containsKey('Externo:1920x1080'), isFalse);
  });

  test('excluir o layout remove os registros de aplicado em cascata', () async {
    const custom = Layout(
      name: 'Temporário',
      regions: [LayoutRegion(name: 'A', x: 0, y: 0, width: 100, height: 100)],
    );
    final saved = (await repository.saveLayout(
      custom,
    )).getOrElse((f) => fail(f.message));

    await repository.setAppliedLayout('Principal:4000x2400', saved.id);
    await repository.deleteLayout(saved.id);

    final applied = (await repository.getAppliedLayouts()).getOrElse(
      (f) => fail(f.message),
    );
    expect(applied, isEmpty);
  });
}
