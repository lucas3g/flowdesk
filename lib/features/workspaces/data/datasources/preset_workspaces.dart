import '../../domain/entities/workspace.dart';

/// Workspaces de exemplo semeados na primeira execução, espelhando o design.
///
/// O nome em [presetWorkspaceLayoutNames] vincula cada workspace ao layout
/// preset correspondente (resolvido para id no momento do seed). Apps não
/// instalados são simplesmente ignorados ao aplicar.
final List<Workspace> presetWorkspaces = [
  const Workspace(
    name: 'Desenvolvimento',
    emoji: '💻',
    gradientStartHex: '#0A84FF',
    gradientEndHex: '#40C8E0',
    shortcut: '⌃1',
    sortOrder: 0,
    apps: [
      WorkspaceApp(bundleId: 'com.microsoft.VSCode', appName: 'VS Code'),
      WorkspaceApp(
        bundleId: 'com.apple.Terminal',
        appName: 'Terminal',
        sortOrder: 1,
      ),
      WorkspaceApp(
        bundleId: 'com.google.Chrome',
        appName: 'Chrome',
        sortOrder: 2,
      ),
    ],
  ),
  const Workspace(
    name: 'Design',
    emoji: '🎨',
    gradientStartHex: '#FF375F',
    gradientEndHex: '#BF5AF2',
    shortcut: '⌃2',
    sortOrder: 1,
    apps: [
      WorkspaceApp(bundleId: 'com.figma.Desktop', appName: 'Figma'),
      WorkspaceApp(
        bundleId: 'com.apple.Safari',
        appName: 'Safari',
        sortOrder: 1,
      ),
    ],
  ),
  const Workspace(
    name: 'Escrita & Pesquisa',
    emoji: '✍️',
    gradientStartHex: '#FF9F0A',
    gradientEndHex: '#FF375F',
    shortcut: '⌃3',
    sortOrder: 2,
    apps: [
      WorkspaceApp(bundleId: 'com.apple.Notes', appName: 'Notas'),
      WorkspaceApp(
        bundleId: 'com.apple.Safari',
        appName: 'Safari',
        sortOrder: 1,
      ),
    ],
  ),
  const Workspace(
    name: 'Comunicação',
    emoji: '💬',
    gradientStartHex: '#30D158',
    gradientEndHex: '#40C8E0',
    shortcut: '⌃4',
    sortOrder: 3,
    apps: [
      WorkspaceApp(bundleId: 'com.tinyspeck.slackmacgap', appName: 'Slack'),
      WorkspaceApp(bundleId: 'us.zoom.xos', appName: 'Zoom', sortOrder: 1),
      WorkspaceApp(bundleId: 'com.apple.mail', appName: 'Mail', sortOrder: 2),
    ],
  ),
  const Workspace(
    name: 'Mídia & Stream',
    emoji: '🎬',
    gradientStartHex: '#BF5AF2',
    gradientEndHex: '#0A84FF',
    shortcut: '⌃5',
    sortOrder: 4,
    apps: [
      WorkspaceApp(bundleId: 'com.obsproject.obs-studio', appName: 'OBS'),
      WorkspaceApp(
        bundleId: 'com.spotify.client',
        appName: 'Spotify',
        sortOrder: 1,
      ),
    ],
  ),
];

/// Workspace → nome do layout preset vinculado no seed.
const Map<String, String> presetWorkspaceLayoutNames = {
  'Desenvolvimento': 'Código & Terminal',
  'Design': 'Grade Design 4×',
  'Escrita & Pesquisa': 'Escrita Zen',
  'Comunicação': 'Reunião & Notas',
  'Mídia & Stream': 'Streaming & Chat',
};
