import '../../domain/entities/layout.dart';

const _blue = '#0A84FF';
const _teal = '#40C8E0';
const _purple = '#BF5AF2';
const _green = '#30D158';
const _orange = '#FF9F0A';
const _pink = '#FF375F';

LayoutRegion _r(
  String name,
  double x,
  double y,
  double w,
  double h,
  String color,
  int order,
) {
  return LayoutRegion(
    name: name,
    x: x,
    y: y,
    width: w,
    height: h,
    colorHex: color,
    sortOrder: order,
  );
}

/// Layouts pré-definidos semeados na primeira execução.
///
/// Regiões em percentuais da área útil; atalhos ⌥1–⌥9 para os nove
/// primeiros, como no design de referência.
final List<Layout> presetLayouts = [
  Layout(
    name: 'Código & Terminal',
    category: LayoutCategory.dev,
    isPreset: true,
    shortcut: '⌥1',
    regions: [
      _r('Editor', 0, 0, 65, 100, _blue, 0),
      _r('Terminal', 65, 0, 35, 55, _teal, 1),
      _r('Logs', 65, 55, 35, 45, _purple, 2),
    ],
  ),
  Layout(
    name: 'Grade Design 4×',
    category: LayoutCategory.design,
    isPreset: true,
    shortcut: '⌥2',
    regions: [
      _r('Canvas', 0, 0, 50, 50, _blue, 0),
      _r('Ferramentas', 50, 0, 50, 50, _purple, 1),
      _r('Referências', 0, 50, 50, 50, _pink, 2),
      _r('Exportação', 50, 50, 50, 50, _teal, 3),
    ],
  ),
  Layout(
    name: 'Foco Central',
    category: LayoutCategory.foco,
    isPreset: true,
    shortcut: '⌥3',
    regions: [_r('Foco', 19, 10, 62, 80, _blue, 0)],
  ),
  Layout(
    name: 'Reunião & Notas',
    category: LayoutCategory.geral,
    isPreset: true,
    shortcut: '⌥4',
    regions: [
      _r('Chamada', 0, 0, 62, 100, _green, 0),
      _r('Notas', 62, 0, 38, 60, _blue, 1),
      _r('Chat', 62, 60, 38, 40, _teal, 2),
    ],
  ),
  Layout(
    name: 'Escrita Zen',
    category: LayoutCategory.foco,
    isPreset: true,
    shortcut: '⌥5',
    regions: [_r('Editor', 25, 6, 50, 88, _orange, 0)],
  ),
  Layout(
    name: 'Pesquisa 3 Colunas',
    category: LayoutCategory.foco,
    isPreset: true,
    shortcut: '⌥6',
    regions: [
      _r('Fontes', 0, 0, 33.34, 100, _teal, 0),
      _r('Documento', 33.34, 0, 33.33, 100, _blue, 1),
      _r('Notas', 66.67, 0, 33.33, 100, _purple, 2),
    ],
  ),
  Layout(
    name: 'Dev + Docs',
    category: LayoutCategory.dev,
    isPreset: true,
    shortcut: '⌥7',
    regions: [
      _r('Código', 0, 0, 58, 100, _blue, 0),
      _r('Documentação', 58, 0, 42, 100, _teal, 1),
    ],
  ),
  Layout(
    name: 'Streaming & Chat',
    category: LayoutCategory.geral,
    isPreset: true,
    shortcut: '⌥8',
    regions: [
      _r('Conteúdo', 0, 0, 70, 70, _purple, 0),
      _r('Chat', 70, 0, 30, 100, _green, 1),
      _r('Controles', 0, 70, 70, 30, _orange, 2),
    ],
  ),
  Layout(
    name: 'Comparar Lado a Lado',
    category: LayoutCategory.geral,
    isPreset: true,
    shortcut: '⌥9',
    regions: [
      _r('Esquerda', 0, 0, 50, 100, _blue, 0),
      _r('Direita', 50, 0, 50, 100, _teal, 1),
    ],
  ),
  Layout(
    name: 'Quadrantes',
    category: LayoutCategory.geral,
    isPreset: true,
    regions: [
      _r('Superior esq.', 0, 0, 50, 50, _blue, 0),
      _r('Superior dir.', 50, 0, 50, 50, _teal, 1),
      _r('Inferior esq.', 0, 50, 50, 50, _purple, 2),
      _r('Inferior dir.', 50, 50, 50, 50, _green, 3),
    ],
  ),
  Layout(
    name: 'Golden Ratio',
    category: LayoutCategory.foco,
    isPreset: true,
    regions: [
      _r('Principal', 0, 0, 61.8, 100, _orange, 0),
      _r('Secundária', 61.8, 0, 38.2, 100, _teal, 1),
    ],
  ),
  Layout(
    name: '4 Colunas',
    category: LayoutCategory.geral,
    isPreset: true,
    regions: [
      _r('Coluna 1', 0, 0, 25, 100, _blue, 0),
      _r('Coluna 2', 25, 0, 25, 100, _teal, 1),
      _r('Coluna 3', 50, 0, 25, 100, _purple, 2),
      _r('Coluna 4', 75, 0, 25, 100, _green, 3),
    ],
  ),
  Layout(
    name: '5 Colunas',
    category: LayoutCategory.ultrawide,
    isPreset: true,
    regions: [
      _r('Coluna 1', 0, 0, 20, 100, _blue, 0),
      _r('Coluna 2', 20, 0, 20, 100, _teal, 1),
      _r('Coluna 3', 40, 0, 20, 100, _purple, 2),
      _r('Coluna 4', 60, 0, 20, 100, _green, 3),
      _r('Coluna 5', 80, 0, 20, 100, _orange, 4),
    ],
  ),
  Layout(
    name: 'Ultrawide 25·50·25',
    category: LayoutCategory.ultrawide,
    isPreset: true,
    regions: [
      _r('Apoio esq.', 0, 0, 25, 100, _teal, 0),
      _r('Principal', 25, 0, 50, 100, _blue, 1),
      _r('Apoio dir.', 75, 0, 25, 100, _purple, 2),
    ],
  ),
];
