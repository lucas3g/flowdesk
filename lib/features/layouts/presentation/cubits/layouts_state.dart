import 'package:equatable/equatable.dart';

import '../../domain/entities/layout.dart';

enum LayoutsStatus { loading, ready, error }

/// Filtro da galeria (pills do design).
enum LayoutsFilter {
  all('Todos'),
  dev('Desenvolvimento'),
  design('Design'),
  foco('Foco'),
  ultrawide('Ultrawide'),
  favorites('★ Favoritos');

  const LayoutsFilter(this.label);

  final String label;
}

/// Estado da galeria de layouts.
class LayoutsState extends Equatable {
  const LayoutsState({
    this.status = LayoutsStatus.loading,
    this.layouts = const [],
    this.filter = LayoutsFilter.all,
    this.query = '',
    this.targetMonitorId,
    this.errorMessage,
    this.feedback,
  });

  final LayoutsStatus status;
  final List<Layout> layouts;
  final LayoutsFilter filter;
  final String query;

  /// Monitor de destino escolhido no seletor da galeria.
  /// `null` = automático (janela em foco ou monitor principal).
  final int? targetMonitorId;
  final String? errorMessage;

  /// Mensagem transitória exibida em snackbar (ex.: "Layout aplicado").
  final String? feedback;

  int get favoritesCount => layouts.where((l) => l.isFavorite).length;

  List<Layout> get filtered {
    final lowerQuery = query.trim().toLowerCase();
    return layouts
        .where((layout) {
          final matchesFilter = switch (filter) {
            LayoutsFilter.all => true,
            LayoutsFilter.dev => layout.category == LayoutCategory.dev,
            LayoutsFilter.design => layout.category == LayoutCategory.design,
            LayoutsFilter.foco => layout.category == LayoutCategory.foco,
            LayoutsFilter.ultrawide =>
              layout.category == LayoutCategory.ultrawide,
            LayoutsFilter.favorites => layout.isFavorite,
          };
          if (!matchesFilter) return false;
          if (lowerQuery.isEmpty) return true;
          return layout.name.toLowerCase().contains(lowerQuery);
        })
        .toList(growable: false);
  }

  LayoutsState copyWith({
    LayoutsStatus? status,
    List<Layout>? layouts,
    LayoutsFilter? filter,
    String? query,
    int? Function()? targetMonitorId,
    String? errorMessage,
    String? feedback,
  }) {
    return LayoutsState(
      status: status ?? this.status,
      layouts: layouts ?? this.layouts,
      filter: filter ?? this.filter,
      query: query ?? this.query,
      targetMonitorId: targetMonitorId != null
          ? targetMonitorId()
          : this.targetMonitorId,
      errorMessage: errorMessage,
      feedback: feedback,
    );
  }

  @override
  List<Object?> get props => [
    status,
    layouts,
    filter,
    query,
    targetMonitorId,
    errorMessage,
    feedback,
  ];
}
