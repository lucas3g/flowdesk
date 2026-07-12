import 'dart:async';

import 'package:flutter/material.dart';

import '../di/injection.dart';
import '../routing/app_screen.dart';
import '../routing/navigation_cubit.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../widgets/ms_icon.dart';
import 'tour_targets.dart';

/// Um passo do tour: destaca [targetKey] (ou mostra um card central quando
/// null) com título e mensagem; [navigateTo] leva à tela certa antes.
class TourStep {
  const TourStep({
    required this.title,
    required this.message,
    this.targetKey,
    this.navigateTo,
  });

  final String title;
  final String message;
  final GlobalKey? targetKey;
  final AppScreen? navigateTo;
}

/// Passos padrão do tour de primeiro uso, na ordem de exibição.
List<TourStep> defaultTourSteps() => [
  TourStep(
    targetKey: TourTargets.sidebarItems[AppScreen.layouts],
    title: 'Layouts',
    message:
        'Sua galeria de layouts: modelos de organização de janelas '
        'prontos e os que você criar.',
  ),
  TourStep(
    targetKey: TourTargets.firstLayoutCard,
    navigateTo: AppScreen.layouts,
    title: 'Aplicar um layout',
    message:
        'Clique em um layout para encaixar as janelas abertas nas '
        'regiões dele — cada janela ganha posição e tamanho.',
  ),
  TourStep(
    targetKey: TourTargets.monitorSelector,
    navigateTo: AppScreen.layouts,
    title: 'Monitor de destino',
    message:
        'Com mais de um monitor, escolha aqui onde os layouts serão '
        'aplicados. A escolha fica salva como padrão.',
  ),
  TourStep(
    targetKey: TourTargets.sidebarItems[AppScreen.workspaces],
    title: 'Workspaces',
    message:
        'Conjuntos de apps + layout ativados de uma vez — ideal para '
        'alternar entre contextos de trabalho.',
  ),
  TourStep(
    targetKey: TourTargets.sidebarItems[AppScreen.shortcuts],
    title: 'Atalhos globais',
    message:
        'Aplique layouts de qualquer app com ⌥1–⌥9 e mova a janela '
        'em foco entre regiões com ⌘⌥←/→.',
  ),
  TourStep(
    targetKey: TourTargets.commandPalette,
    title: 'Paleta de comandos',
    message: 'Pressione ⌘K para buscar e executar qualquer ação do FlowDesk.',
  ),
  TourStep(
    targetKey: TourTargets.sidebarItems[AppScreen.settings],
    title: 'Configurações',
    message:
        'Ajuste espaçamentos, encaixe magnético e permissões. O FlowDesk '
        'também vive na barra de menus — bom trabalho!',
  ),
];

/// Exibe o tour guiado por cima do shell; resolve quando o usuário conclui
/// ou pula. [onFinished] é chamado em ambos os casos.
Future<void> showFeatureTour(
  BuildContext context, {
  List<TourStep>? steps,
  VoidCallback? onFinished,
}) {
  final overlay = Overlay.of(context, rootOverlay: true);
  final completer = Completer<void>();
  late final OverlayEntry entry;

  entry = OverlayEntry(
    builder: (_) => _FeatureTourOverlay(
      steps: steps ?? defaultTourSteps(),
      onClose: () {
        entry.remove();
        onFinished?.call();
        completer.complete();
      },
    ),
  );
  overlay.insert(entry);
  return completer.future;
}

class _FeatureTourOverlay extends StatefulWidget {
  const _FeatureTourOverlay({required this.steps, required this.onClose});

  final List<TourStep> steps;
  final VoidCallback onClose;

  @override
  State<_FeatureTourOverlay> createState() => _FeatureTourOverlayState();
}

class _FeatureTourOverlayState extends State<_FeatureTourOverlay>
    with WidgetsBindingObserver {
  final NavigationCubit _navigationCubit = getIt<NavigationCubit>();

  int _index = -1;

  /// Retângulo do alvo atual em coordenadas globais; null = card central.
  Rect? _targetRect;
  bool _resolving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _advance();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Janela redimensionada: o alvo mudou de lugar, re-resolve o retângulo.
  @override
  void didChangeMetrics() {
    final step = _currentStep;
    if (step == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _targetRect = _rectOf(step.targetKey));
    });
  }

  TourStep? get _currentStep =>
      _index >= 0 && _index < widget.steps.length ? widget.steps[_index] : null;

  /// Avança para o próximo passo cujo alvo exista (ou sem alvo); passos com
  /// alvo não montado são pulados. Sem passos restantes, encerra.
  Future<void> _advance() async {
    if (_resolving) return;
    _resolving = true;
    try {
      var next = _index + 1;
      while (next < widget.steps.length) {
        final step = widget.steps[next];

        if (step.navigateTo != null) {
          _navigationCubit.navigate(step.navigateTo!);
          // Espera a transição de tela para o alvo montar e assentar.
          await Future<void>.delayed(
            AppDimens.transitionScreen + const Duration(milliseconds: 60),
          );
          if (!mounted) return;
        }

        final rect = _rectOf(step.targetKey);
        if (step.targetKey == null || rect != null) {
          setState(() {
            _index = next;
            _targetRect = rect;
          });
          return;
        }
        next++; // Alvo não montado (ex.: galeria vazia): pula o passo.
      }
      widget.onClose();
    } finally {
      _resolving = false;
    }
  }

  Rect? _rectOf(GlobalKey? key) {
    final renderObject = key?.currentContext?.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) return null;
    return renderObject.localToGlobal(Offset.zero) & renderObject.size;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final step = _currentStep;
    if (step == null) return const SizedBox.shrink();

    final screen = MediaQuery.sizeOf(context);
    final spotlight = _targetRect?.inflate(6);

    return Stack(
      children: [
        // Scrim com recorte no alvo; absorve cliques fora do balão.
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {},
            child: TweenAnimationBuilder<Rect?>(
              tween: RectTween(end: spotlight ?? Rect.zero),
              duration: AppDimens.transitionScreen,
              curve: Curves.easeOutCubic,
              builder: (context, rect, _) => CustomPaint(
                painter: _SpotlightPainter(
                  cutout: spotlight == null ? null : rect,
                  borderColor: colors.blue,
                ),
              ),
            ),
          ),
        ),
        _TourBalloon(
          step: step,
          index: _index,
          total: widget.steps.length,
          spotlight: spotlight,
          screen: screen,
          onSkip: widget.onClose,
          onNext: _advance,
        ),
      ],
    );
  }
}

/// Escurece a tela toda, exceto o retângulo do alvo (recorte arredondado
/// com borda de destaque).
class _SpotlightPainter extends CustomPainter {
  const _SpotlightPainter({required this.cutout, required this.borderColor});

  final Rect? cutout;
  final Color borderColor;

  @override
  void paint(Canvas canvas, Size size) {
    final scrim = Path()..addRect(Offset.zero & size);
    final paint = Paint()..color = Colors.black.withValues(alpha: 0.62);

    if (cutout == null || cutout!.isEmpty) {
      canvas.drawPath(scrim, paint);
      return;
    }

    final hole = RRect.fromRectAndRadius(cutout!, const Radius.circular(10));
    final cut = Path()..addRRect(hole);
    canvas.drawPath(Path.combine(PathOperation.difference, scrim, cut), paint);
    canvas.drawRRect(
      hole,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = borderColor,
    );
  }

  @override
  bool shouldRepaint(_SpotlightPainter oldDelegate) =>
      oldDelegate.cutout != cutout || oldDelegate.borderColor != borderColor;
}

/// Balão do passo atual, posicionado ao lado do alvo (abaixo/acima/direita
/// conforme o espaço) ou centralizado quando não há alvo.
class _TourBalloon extends StatelessWidget {
  const _TourBalloon({
    required this.step,
    required this.index,
    required this.total,
    required this.spotlight,
    required this.screen,
    required this.onSkip,
    required this.onNext,
  });

  final TourStep step;
  final int index;
  final int total;
  final Rect? spotlight;
  final Size screen;
  final VoidCallback onSkip;
  final VoidCallback onNext;

  static const double _width = 320;
  static const double _estimatedHeight = 170;
  static const double _gap = 14;

  @override
  Widget build(BuildContext context) {
    final rect = spotlight;
    if (rect == null) {
      return Center(child: _card(context));
    }

    // Prefere abaixo do alvo; sem espaço, acima; senão ao lado direito.
    final double left;
    final double top;
    if (rect.bottom + _gap + _estimatedHeight < screen.height) {
      top = rect.bottom + _gap;
      left = rect.left;
    } else if (rect.top - _gap - _estimatedHeight > 0) {
      top = rect.top - _gap - _estimatedHeight;
      left = rect.left;
    } else {
      top = rect.top;
      left = rect.right + _gap;
    }

    return Positioned(
      left: left.clamp(12.0, screen.width - _width - 12.0),
      top: top.clamp(12.0, screen.height - _estimatedHeight - 12.0),
      child: _card(context),
    );
  }

  Widget _card(BuildContext context) {
    final colors = context.colors;
    final isLast = index == total - 1;

    return Material(
      color: Colors.transparent,
      child: Container(
        width: _width,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.panel,
          borderRadius: BorderRadius.circular(AppDimens.radiusCardLarge),
          border: Border.all(color: colors.cardBorder),
          boxShadow: const [
            BoxShadow(
              color: Colors.black38,
              blurRadius: 24,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                MsIcon('tips_and_updates', size: 16, color: colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    step.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: colors.text,
                    ),
                  ),
                ),
                Text(
                  '${index + 1} de $total',
                  style: TextStyle(fontSize: 11, color: colors.text3),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              step.message,
              style: TextStyle(
                fontSize: 12.5,
                height: 1.45,
                color: colors.text2,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                TextButton(
                  onPressed: onSkip,
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  child: Text(
                    'Pular tour',
                    style: TextStyle(fontSize: 12, color: colors.text3),
                  ),
                ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: onNext,
                  style: FilledButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  icon: MsIcon(
                    isLast ? 'check' : 'arrow_forward',
                    size: 14,
                    color: Colors.white,
                  ),
                  label: Text(isLast ? 'Concluir' : 'Próximo'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
