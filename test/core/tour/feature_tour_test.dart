import 'package:flowdesk/core/theme/app_theme.dart';
import 'package:flowdesk/core/tour/feature_tour.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_fonts.dart';

/// App mínimo com um widget-alvo identificado por [targetKey].
Widget _host(GlobalKey targetKey) {
  return MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(
      body: Center(child: SizedBox(key: targetKey, width: 120, height: 40)),
    ),
  );
}

void main() {
  setUpAll(loadMaterialSymbolsFont);

  testWidgets('exibe o balão do passo e conclui ao avançar', (tester) async {
    final targetKey = GlobalKey();
    var finished = false;

    await tester.pumpWidget(_host(targetKey));
    final context = tester.element(find.byKey(targetKey));

    showFeatureTour(
      context,
      steps: [
        TourStep(targetKey: targetKey, title: 'Alvo', message: 'Descrição.'),
        const TourStep(title: 'Final', message: 'Sem alvo, card central.'),
      ],
      onFinished: () => finished = true,
    );
    await tester.pumpAndSettle();

    expect(find.text('Alvo'), findsOneWidget);
    expect(find.text('1 de 2'), findsOneWidget);
    expect(find.text('Próximo'), findsOneWidget);

    await tester.tap(find.text('Próximo'));
    await tester.pumpAndSettle();
    expect(find.text('Final'), findsOneWidget);
    expect(find.text('Concluir'), findsOneWidget);

    await tester.tap(find.text('Concluir'));
    await tester.pumpAndSettle();
    expect(find.text('Final'), findsNothing);
    expect(finished, isTrue);
  });

  testWidgets('pular encerra o tour imediatamente', (tester) async {
    final targetKey = GlobalKey();
    var finished = false;

    await tester.pumpWidget(_host(targetKey));
    final context = tester.element(find.byKey(targetKey));

    showFeatureTour(
      context,
      steps: [
        TourStep(targetKey: targetKey, title: 'Alvo', message: 'Descrição.'),
        const TourStep(title: 'Nunca visto', message: '...'),
      ],
      onFinished: () => finished = true,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Pular tour'));
    await tester.pumpAndSettle();

    expect(find.text('Alvo'), findsNothing);
    expect(finished, isTrue);
  });

  testWidgets('passo com alvo não montado é pulado', (tester) async {
    final targetKey = GlobalKey();
    final missingKey = GlobalKey();

    await tester.pumpWidget(_host(targetKey));
    final context = tester.element(find.byKey(targetKey));

    showFeatureTour(
      context,
      steps: [
        TourStep(
          targetKey: missingKey,
          title: 'Invisível',
          message: 'Alvo não montado.',
        ),
        TourStep(targetKey: targetKey, title: 'Visível', message: 'Ok.'),
      ],
    );
    await tester.pumpAndSettle();

    expect(find.text('Invisível'), findsNothing);
    expect(find.text('Visível'), findsOneWidget);
    // O passo pulado não conta a menos no rótulo — total segue o definido.
    expect(find.text('2 de 2'), findsOneWidget);

    await tester.tap(find.text('Concluir'));
    await tester.pumpAndSettle();
  });
}
