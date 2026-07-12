import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:window_manager/window_manager.dart';

import '../../features/settings/presentation/cubits/settings_cubit.dart';

/// Intercepta o fechamento da janela (botão X): em vez de encerrar o app,
/// apenas esconde a janela — no macOS o app segue vivo na Dock e no menu bar;
/// no Windows fica acessível pelo ícone na bandeja do sistema, onde o menu de
/// contexto oferece "Sair do FlowDesk".
@lazySingleton
class WindowCloseService with WindowListener {
  WindowCloseService(this._settingsCubit);

  final SettingsCubit _settingsCubit;

  Future<void> start() async {
    windowManager.addListener(this);
    await windowManager.setPreventClose(true);
  }

  @override
  Future<void> onWindowClose() async {
    final settings = _settingsCubit.state.settings;
    // Se o usuário desativou todos os pontos de retorno visíveis (Dock e menu
    // bar no macOS, bandeja no Windows), fechar encerra de verdade para o app
    // não ficar rodando inacessível.
    final hasReentry = Platform.isMacOS
        ? settings.showInDock || settings.showMenuBarIcon
        : settings.showMenuBarIcon;
    if (!hasReentry) {
      await windowManager.destroy();
      return;
    }
    await windowManager.hide();
  }
}
