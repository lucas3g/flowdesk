import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../layouts/domain/entities/layout.dart';
import '../../../layouts/domain/usecases/save_layout.dart';
import '../../../layouts/presentation/cubits/layouts_cubit.dart';
import 'layout_editor_state.dart';

/// Editor visual: manipula as regiões do layout em edição com snap na
/// grade 20×12 e persiste via [SaveLayout].
@lazySingleton
class LayoutEditorCubit extends Cubit<LayoutEditorState> {
  LayoutEditorCubit(this._saveLayout, this._layoutsCubit)
    : super(const LayoutEditorState());

  final SaveLayout _saveLayout;
  final LayoutsCubit _layoutsCubit;

  static const List<String> _palette = [
    '#0A84FF',
    '#40C8E0',
    '#BF5AF2',
    '#30D158',
    '#FF9F0A',
    '#FF375F',
  ];

  double get _stepX => 100 / LayoutEditorState.gridColumns;
  double get _stepY => 100 / LayoutEditorState.gridRows;

  /// Começa um layout vazio.
  void newLayout() {
    emit(
      const LayoutEditorState().copyWith(
        gridVisible: state.gridVisible,
        snapEnabled: state.snapEnabled,
      ),
    );
  }

  /// Abre um layout para edição; presets abrem como cópia editável.
  void loadForEdit(Layout layout) {
    final editable = layout.isPreset
        ? layout.copyWith(
            id: 0,
            name: '${layout.name} (cópia)',
            isPreset: false,
            shortcut: () => null,
          )
        : layout;
    emit(
      LayoutEditorState(
        layout: editable,
        gridVisible: state.gridVisible,
        snapEnabled: state.snapEnabled,
      ),
    );
  }

  void setName(String name) {
    if (name == state.layout.name) return;
    emit(
      state.copyWith(layout: state.layout.copyWith(name: name), isDirty: true),
    );
  }

  void toggleGrid() => emit(state.copyWith(gridVisible: !state.gridVisible));

  void toggleSnap() => emit(state.copyWith(snapEnabled: !state.snapEnabled));

  void select(int? index) => emit(state.copyWith(selectedIndex: () => index));

  /// Adiciona uma região central padrão.
  void addRegion() {
    final index = state.layout.regions.length;
    final region = LayoutRegion(
      name: 'Região ${index + 1}',
      x: 30,
      y: 30,
      width: 40,
      height: 40,
      colorHex: _palette[index % _palette.length],
      sortOrder: index,
    );
    _updateRegions([...state.layout.regions, region], selectIndex: index);
  }

  /// Cria uma região a partir de um arrasto no canvas (valores em %).
  void addRegionAt(double x, double y, double width, double height) {
    if (width < LayoutEditorState.minRegionSize ||
        height < LayoutEditorState.minRegionSize) {
      return;
    }
    final index = state.layout.regions.length;
    final snapped = _snapFrame(x: x, y: y, width: width, height: height);
    final region = LayoutRegion(
      name: 'Região ${index + 1}',
      x: snapped.$1,
      y: snapped.$2,
      width: snapped.$3,
      height: snapped.$4,
      colorHex: _palette[index % _palette.length],
      sortOrder: index,
    );
    _updateRegions([...state.layout.regions, region], selectIndex: index);
  }

  /// Atualiza o frame de uma região (arrasto/redimensionamento/inspector).
  void setFrame(
    int index, {
    double? x,
    double? y,
    double? width,
    double? height,
  }) {
    final region = _regionAt(index);
    if (region == null) return;

    final snapped = _snapFrame(
      x: x ?? region.x,
      y: y ?? region.y,
      width: width ?? region.width,
      height: height ?? region.height,
    );

    _replaceRegion(
      index,
      region.copyWith(
        x: snapped.$1,
        y: snapped.$2,
        width: snapped.$3,
        height: snapped.$4,
      ),
    );
  }

  void renameRegion(int index, String name) {
    final region = _regionAt(index);
    if (region == null || name.trim().isEmpty) return;
    _replaceRegion(index, region.copyWith(name: name));
  }

  void setRegionColor(int index, String colorHex) {
    final region = _regionAt(index);
    if (region == null) return;
    _replaceRegion(index, region.copyWith(colorHex: colorHex));
  }

  /// Associa um app à região (null remove a associação). Ao aplicar o
  /// layout, a janela desse app ocupa esta região.
  ///
  /// Ao associar, o nome da região passa a ser o do app (a menos que já
  /// tenha um nome personalizado diferente do padrão "Região N").
  void setRegionApp(
    int index, {
    String? bundleId,
    String? appName,
    String? windowTitle,
  }) {
    final region = _regionAt(index);
    if (region == null) return;

    final hasCustomName =
        region.appName == null &&
        !RegExp(r'^Região \d+$').hasMatch(region.name);
    final newName = bundleId != null && appName != null && !hasCustomName
        ? appName
        : region.name;

    _replaceRegion(
      index,
      region.copyWith(
        name: newName,
        appBundleId: () => bundleId,
        appName: () => appName,
        appWindowTitle: () => windowTitle,
      ),
    );
  }

  /// Traz a região para a frente (fim da lista, desenhada por último).
  void bringRegionToFront(int index) =>
      _moveRegion(index, state.layout.regions.length - 1);

  /// Envia a região para trás (início da lista, desenhada primeiro).
  void sendRegionToBack(int index) => _moveRegion(index, 0);

  void deleteRegion(int index) {
    if (_regionAt(index) == null) return;
    final regions = [...state.layout.regions]..removeAt(index);
    _updateRegions(regions, selectIndex: null);
  }

  /// Aplica um preset de frame à região selecionada.
  void applyPreset(RegionPreset preset) {
    final index = state.selectedIndex;
    if (index == null) return;
    setFrame(
      index,
      x: preset.x,
      y: preset.y,
      width: preset.width,
      height: preset.height,
    );
  }

  Future<void> save() async {
    final result = await _saveLayout(state.layout);
    await result.fold(
      (failure) async => emit(state.copyWith(feedback: failure.message)),
      (saved) async {
        emit(
          state.copyWith(
            layout: saved,
            isDirty: false,
            feedback: "Layout '${saved.name}' salvo.",
          ),
        );
        await _layoutsCubit.load();
      },
    );
  }

  void clearFeedback() {
    if (state.feedback != null) emit(state.copyWith());
  }

  // MARK: - Internos

  LayoutRegion? _regionAt(int index) =>
      index >= 0 && index < state.layout.regions.length
      ? state.layout.regions[index]
      : null;

  /// Move a região para outra posição da lista, reatribuindo os
  /// [LayoutRegion.sortOrder] (a ordem da lista é a ordem de desenho).
  void _moveRegion(int index, int newIndex) {
    final region = _regionAt(index);
    if (region == null || index == newIndex) return;

    final regions = [...state.layout.regions]
      ..removeAt(index)
      ..insert(newIndex, region);
    _updateRegions([
      for (var i = 0; i < regions.length; i++)
        regions[i].copyWith(sortOrder: i),
    ], selectIndex: newIndex);
  }

  void _replaceRegion(int index, LayoutRegion region) {
    final regions = [...state.layout.regions];
    regions[index] = region;
    _updateRegions(regions, selectIndex: state.selectedIndex);
  }

  void _updateRegions(List<LayoutRegion> regions, {int? selectIndex}) {
    emit(
      state.copyWith(
        layout: state.layout.copyWith(regions: regions),
        selectedIndex: () => selectIndex,
        isDirty: true,
      ),
    );
  }

  /// Aplica snap (quando ativo) e garante limites e tamanho mínimo.
  (double, double, double, double) _snapFrame({
    required double x,
    required double y,
    required double width,
    required double height,
  }) {
    double snap(double value, double step) =>
        state.snapEnabled ? (value / step).round() * step : value;

    var w = snap(width, _stepX).clamp(LayoutEditorState.minRegionSize, 100.0);
    var h = snap(height, _stepY).clamp(LayoutEditorState.minRegionSize, 100.0);
    final px = snap(x, _stepX).clamp(0.0, 100.0 - w);
    final py = snap(y, _stepY).clamp(0.0, 100.0 - h);
    w = w.clamp(LayoutEditorState.minRegionSize, 100.0 - px);
    h = h.clamp(LayoutEditorState.minRegionSize, 100.0 - py);

    double round(double value) => (value * 100).roundToDouble() / 100;
    return (round(px), round(py), round(w), round(h));
  }
}
