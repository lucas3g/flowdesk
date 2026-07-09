/// Seções da sidebar, na ordem do design.
enum SidebarSection {
  overview('VISÃO GERAL'),
  organization('ORGANIZAÇÃO'),
  system('SISTEMA');

  const SidebarSection(this.title);

  final String title;
}

/// Telas navegáveis do app, na ordem em que aparecem na sidebar.
enum AppScreen {
  dashboard('Dashboard', 'space_dashboard', SidebarSection.overview),
  layouts('Layouts', 'dashboard_customize', SidebarSection.overview),
  layoutEditor('Editor de Layout', 'draw', SidebarSection.overview),
  workspaces('Workspace', 'workspaces', SidebarSection.organization),
  monitors('Monitores', 'monitor', SidebarSection.organization),
  windows('Janelas', 'select_window', SidebarSection.organization),
  rules('Regras', 'account_tree', SidebarSection.organization),
  shortcuts('Atalhos', 'keyboard_command_key', SidebarSection.system),
  history('Histórico', 'history', SidebarSection.system),
  favorites('Favoritos', 'star', SidebarSection.system),
  backup('Backup', 'cloud_sync', SidebarSection.system),
  settings('Configurações', 'settings', SidebarSection.system);

  const AppScreen(this.label, this.iconName, this.section);

  final String label;

  /// Nome do glifo em Material Symbols Rounded.
  final String iconName;

  final SidebarSection section;

  /// Título exibido no breadcrumb da titlebar (Dashboard não exibe título).
  String? get breadcrumbTitle => this == AppScreen.dashboard ? null : label;
}
