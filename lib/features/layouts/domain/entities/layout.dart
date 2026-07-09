import 'package:equatable/equatable.dart';

/// Categoria usada nos filtros da galeria.
enum LayoutCategory {
  dev('Desenvolvimento'),
  design('Design'),
  foco('Foco'),
  geral('Geral'),
  ultrawide('Ultrawide');

  const LayoutCategory(this.label);

  final String label;

  static LayoutCategory fromName(String name) => LayoutCategory.values
      .firstWhere((c) => c.name == name, orElse: () => LayoutCategory.geral);
}

/// Região de um layout, em percentuais (0–100) da área útil do monitor.
class LayoutRegion extends Equatable {
  const LayoutRegion({
    this.id = 0,
    required this.name,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    this.colorHex = '#0A84FF',
    this.sortOrder = 0,
    this.appBundleId,
    this.appName,
    this.appWindowTitle,
  });

  final int id;
  final String name;
  final double x;
  final double y;
  final double width;
  final double height;
  final String colorHex;
  final int sortOrder;

  /// App associado: ao aplicar o layout, a janela desse app vai para
  /// esta região (null = qualquer janela, por ordem).
  final String? appBundleId;
  final String? appName;

  /// Título da janela escolhida quando o app tem várias instâncias abertas
  /// (null = qualquer janela do app, preferindo a maior).
  final String? appWindowTitle;

  bool get hasApp => appBundleId != null && appBundleId!.isNotEmpty;

  bool get hasWindowTitle =>
      appWindowTitle != null && appWindowTitle!.isNotEmpty;

  LayoutRegion copyWith({
    int? id,
    String? name,
    double? x,
    double? y,
    double? width,
    double? height,
    String? colorHex,
    int? sortOrder,
    String? Function()? appBundleId,
    String? Function()? appName,
    String? Function()? appWindowTitle,
  }) {
    return LayoutRegion(
      id: id ?? this.id,
      name: name ?? this.name,
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
      colorHex: colorHex ?? this.colorHex,
      sortOrder: sortOrder ?? this.sortOrder,
      appBundleId: appBundleId != null ? appBundleId() : this.appBundleId,
      appName: appName != null ? appName() : this.appName,
      appWindowTitle: appWindowTitle != null
          ? appWindowTitle()
          : this.appWindowTitle,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    x,
    y,
    width,
    height,
    colorHex,
    sortOrder,
    appBundleId,
    appName,
    appWindowTitle,
  ];
}

/// Layout de janelas: um conjunto ordenado de regiões nomeadas.
class Layout extends Equatable {
  const Layout({
    this.id = 0,
    required this.name,
    this.category = LayoutCategory.geral,
    this.isFavorite = false,
    this.isPreset = false,
    this.shortcut,
    this.regions = const [],
  });

  /// 0 indica layout ainda não persistido.
  final int id;
  final String name;
  final LayoutCategory category;
  final bool isFavorite;

  /// Presets são semeados pelo app e não podem ser excluídos.
  final bool isPreset;

  /// Atalho de exibição (ex.: `⌥1`).
  final String? shortcut;
  final List<LayoutRegion> regions;

  Layout copyWith({
    int? id,
    String? name,
    LayoutCategory? category,
    bool? isFavorite,
    bool? isPreset,
    String? Function()? shortcut,
    List<LayoutRegion>? regions,
  }) {
    return Layout(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      isFavorite: isFavorite ?? this.isFavorite,
      isPreset: isPreset ?? this.isPreset,
      shortcut: shortcut != null ? shortcut() : this.shortcut,
      regions: regions ?? this.regions,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    category,
    isFavorite,
    isPreset,
    shortcut,
    regions,
  ];
}
