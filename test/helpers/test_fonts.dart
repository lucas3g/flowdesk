import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Carrega a fonte Material Symbols nos widget tests para que os glifos
/// sejam renderizados por ligadura (sem isso, o nome do ícone vira texto
/// longo e estoura os layouts).
Future<void> loadMaterialSymbolsFont() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  final loader = FontLoader('MaterialSymbolsRounded')
    ..addFont(rootBundle.load('assets/fonts/MaterialSymbolsRounded.ttf'));
  await loader.load();
}
