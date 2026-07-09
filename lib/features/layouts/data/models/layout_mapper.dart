import 'package:drift/drift.dart';

import '../../../../core/services/database/app_database.dart';
import '../../domain/entities/layout.dart';

/// Conversões entre linhas do banco e entidades de layout.
abstract final class LayoutMapper {
  static Layout fromRows(LayoutRow layout, List<LayoutRegionRow> regions) {
    final sorted = [...regions]
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return Layout(
      id: layout.id,
      name: layout.name,
      category: LayoutCategory.fromName(layout.category),
      isFavorite: layout.isFavorite,
      isPreset: layout.isPreset,
      shortcut: layout.shortcut,
      regions: [
        for (final region in sorted)
          LayoutRegion(
            id: region.id,
            name: region.name,
            x: region.x,
            y: region.y,
            width: region.width,
            height: region.height,
            colorHex: region.colorHex,
            sortOrder: region.sortOrder,
            appBundleId: region.appBundleId,
            appName: region.appName,
            appWindowTitle: region.appWindowTitle,
          ),
      ],
    );
  }

  static LayoutsCompanion toLayoutCompanion(Layout layout) {
    return LayoutsCompanion(
      id: layout.id == 0 ? const Value.absent() : Value(layout.id),
      name: Value(layout.name),
      category: Value(layout.category.name),
      isFavorite: Value(layout.isFavorite),
      isPreset: Value(layout.isPreset),
      shortcut: Value(layout.shortcut),
      updatedAt: Value(DateTime.now()),
    );
  }

  static LayoutRegionsCompanion toRegionCompanion(
    LayoutRegion region,
    int layoutId,
    int sortOrder,
  ) {
    return LayoutRegionsCompanion(
      layoutId: Value(layoutId),
      name: Value(region.name),
      x: Value(region.x),
      y: Value(region.y),
      width: Value(region.width),
      height: Value(region.height),
      colorHex: Value(region.colorHex),
      sortOrder: Value(sortOrder),
      appBundleId: Value(region.appBundleId),
      appName: Value(region.appName),
      appWindowTitle: Value(region.appWindowTitle),
    );
  }
}
