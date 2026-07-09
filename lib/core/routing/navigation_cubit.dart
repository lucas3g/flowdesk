import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'app_screen.dart';

/// Controla a tela ativa do shell (navegação por estado, sem URLs,
/// espelhando o comportamento do design de referência).
@lazySingleton
class NavigationCubit extends Cubit<AppScreen> {
  NavigationCubit() : super(AppScreen.dashboard);

  void navigate(AppScreen screen) {
    if (screen != state) emit(screen);
  }
}
