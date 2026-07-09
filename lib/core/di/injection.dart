import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'injection.config.dart';

final GetIt getIt = GetIt.instance;

/// Registra todas as dependências anotadas com Injectable.
@InjectableInit()
Future<void> configureDependencies() async => getIt.init();
