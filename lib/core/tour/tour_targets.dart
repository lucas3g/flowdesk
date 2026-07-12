import 'package:flutter/widgets.dart';

import '../routing/app_screen.dart';

/// Keys globais dos widgets destacados pelo tour de primeiro uso.
///
/// Os widgets-alvo recebem estas keys; o tour resolve o retângulo de cada
/// um pelo RenderBox para posicionar o spotlight.
abstract final class TourTargets {
  /// Itens da sidebar destacados no tour (por tela).
  static final Map<AppScreen, GlobalKey> sidebarItems = {
    AppScreen.layouts: GlobalKey(debugLabel: 'tour-sidebar-layouts'),
    AppScreen.workspaces: GlobalKey(debugLabel: 'tour-sidebar-workspaces'),
    AppScreen.shortcuts: GlobalKey(debugLabel: 'tour-sidebar-shortcuts'),
    AppScreen.settings: GlobalKey(debugLabel: 'tour-sidebar-settings'),
  };

  /// Primeiro card da galeria de layouts.
  static final GlobalKey firstLayoutCard = GlobalKey(
    debugLabel: 'tour-first-layout-card',
  );

  /// Seletor "Aplicar em" (monitor padrão) na galeria de layouts.
  static final GlobalKey monitorSelector = GlobalKey(
    debugLabel: 'tour-monitor-selector',
  );

  /// Gatilho da paleta de comandos (⌘K) na titlebar.
  static final GlobalKey commandPalette = GlobalKey(
    debugLabel: 'tour-command-palette',
  );
}
