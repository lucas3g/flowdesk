import 'package:equatable/equatable.dart';

import '../../../layouts/domain/entities/layout.dart';

/// Presets rápidos aplicáveis à região selecionada.
enum RegionPreset {
  fullScreen('Tela cheia', 0, 0, 100, 100),
  leftHalf('Metade esq.', 0, 0, 50, 100),
  rightHalf('Metade dir.', 50, 0, 50, 100),
  third('Terço', 0, 0, 33.33, 100),
  center('Centro', 20, 15, 60, 70),
  corner('Canto', 55, 55, 45, 45);

  const RegionPreset(this.label, this.x, this.y, this.width, this.height);

  final String label;
  final double x;
  final double y;
  final double width;
  final double height;
}

/// Estado do editor visual de layouts.
class LayoutEditorState extends Equatable {
  const LayoutEditorState({
    this.layout = const Layout(name: 'Novo layout'),
    this.selectedIndex,
    this.gridVisible = true,
    this.snapEnabled = true,
    this.isDirty = false,
    this.feedback,
  });

  /// Grade do design: 20 colunas × 12 linhas.
  static const int gridColumns = 20;
  static const int gridRows = 12;
  static const double minRegionSize = 8;

  final Layout layout;
  final int? selectedIndex;
  final bool gridVisible;
  final bool snapEnabled;

  /// Há alterações não salvas.
  final bool isDirty;

  /// Mensagem transitória (ex.: "Layout salvo").
  final String? feedback;

  LayoutRegion? get selected =>
      selectedIndex != null && selectedIndex! < layout.regions.length
      ? layout.regions[selectedIndex!]
      : null;

  LayoutEditorState copyWith({
    Layout? layout,
    int? Function()? selectedIndex,
    bool? gridVisible,
    bool? snapEnabled,
    bool? isDirty,
    String? feedback,
  }) {
    return LayoutEditorState(
      layout: layout ?? this.layout,
      selectedIndex: selectedIndex != null
          ? selectedIndex()
          : this.selectedIndex,
      gridVisible: gridVisible ?? this.gridVisible,
      snapEnabled: snapEnabled ?? this.snapEnabled,
      isDirty: isDirty ?? this.isDirty,
      feedback: feedback,
    );
  }

  @override
  List<Object?> get props => [
    layout,
    selectedIndex,
    gridVisible,
    snapEnabled,
    isDirty,
    feedback,
  ];
}
