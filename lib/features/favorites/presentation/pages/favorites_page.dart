import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/ms_icon.dart';
import '../../../layouts/presentation/cubits/layouts_cubit.dart';
import '../../../layouts/presentation/cubits/layouts_state.dart';
import '../../../layouts/presentation/widgets/layout_preview.dart';

/// Tela de Favoritos: layouts marcados com estrela, com aplicação rápida.
class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final LayoutsCubit _cubit = getIt<LayoutsCubit>();

  @override
  void initState() {
    super.initState();
    _cubit.load();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return BlocBuilder<LayoutsCubit, LayoutsState>(
      bloc: _cubit,
      builder: (context, state) {
        final favorites = state.layouts
            .where((layout) => layout.isFavorite)
            .toList(growable: false);

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            vertical: AppDimens.pagePaddingVertical,
            horizontal: AppDimens.pagePaddingHorizontal,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Favoritos',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${favorites.length} layouts favoritos',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 20),
                  if (favorites.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Column(
                          children: [
                            MsIcon('star', size: 28, color: colors.text3),
                            const SizedBox(height: 10),
                            Text(
                              'Nenhum favorito ainda — marque layouts com a '
                              'estrela na galeria.',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Container(
                      decoration: BoxDecoration(
                        color: colors.card,
                        borderRadius: BorderRadius.circular(
                          AppDimens.radiusCard,
                        ),
                        border: Border.all(color: colors.cardBorder),
                      ),
                      child: Column(
                        children: [
                          for (var i = 0; i < favorites.length; i++) ...[
                            if (i > 0)
                              Divider(
                                height: 1,
                                indent: 84,
                                color: colors.separator,
                              ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 58,
                                    height: 36,
                                    child: LayoutPreview(
                                      layout: favorites[i],
                                      showLabels: false,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          favorites[i].name,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodyMedium,
                                        ),
                                        Text(
                                          '${favorites[i].regions.length} '
                                          'regiões · '
                                          '${favorites[i].category.label}',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: colors.text3,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (favorites[i].shortcut != null)
                                    Container(
                                      margin: const EdgeInsets.only(right: 8),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: colors.cardBorder,
                                        ),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: Text(
                                        favorites[i].shortcut!,
                                        style: TextStyle(
                                          fontSize: 10.5,
                                          color: colors.text3,
                                        ),
                                      ),
                                    ),
                                  FilledButton.icon(
                                    onPressed: () =>
                                        _cubit.apply(favorites[i]),
                                    style: FilledButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 7,
                                      ),
                                      textStyle: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    icon: const MsIcon(
                                      'bolt',
                                      size: 13,
                                      color: Colors.white,
                                    ),
                                    label: const Text('Aplicar'),
                                  ),
                                  const SizedBox(width: 4),
                                  Tooltip(
                                    message: 'Remover dos favoritos',
                                    child: InkWell(
                                      onTap: () =>
                                          _cubit.toggleFavorite(favorites[i]),
                                      borderRadius: BorderRadius.circular(7),
                                      hoverColor: colors.hover,
                                      child: SizedBox(
                                        width: 30,
                                        height: 30,
                                        child: Center(
                                          child: MsIcon(
                                            'star',
                                            size: 15,
                                            filled: true,
                                            color: colors.orange,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
