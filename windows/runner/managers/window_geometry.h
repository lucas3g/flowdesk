#ifndef RUNNER_MANAGERS_WINDOW_GEOMETRY_H_
#define RUNNER_MANAGERS_WINDOW_GEOMETRY_H_

#include <windows.h>

// Geometria de janelas compensando as bordas invisíveis do DWM.
//
// No Windows 10/11 o retângulo de `GetWindowRect`/`SetWindowPos` inclui uma
// moldura de redimensionamento transparente (~7-8px por lado a 100% de DPI,
// nas laterais e embaixo). O que o usuário enxerga é o retângulo devolvido
// por `DWMWA_EXTENDED_FRAME_BOUNDS`. Sem compensar essa diferença, uma janela
// encaixada numa região aparece "encolhida", com folga nas bordas — por isso
// todo posicionamento do FlowDesk passa por aqui.
//
// Todas as coordenadas são pixels físicos da área de trabalho virtual (o
// processo é PerMonitorV2, ver runner.exe.manifest), o mesmo sistema usado
// pelo MonitorManager e pelas regiões enviadas pelo Dart.
namespace window_geometry {

// Diferença, por lado, entre o retângulo externo e o frame visual.
struct FramePadding {
  LONG left = 0;
  LONG top = 0;
  LONG right = 0;
  LONG bottom = 0;
};

// Padding da janela; {0,0,0,0} quando o DWM não informa ou o valor é
// implausível (nesse caso o comportamento equivale a não compensar nada).
FramePadding PaddingOf(HWND hwnd);

// Frame visual da janela. Usa o retângulo externo como fallback.
bool VisualRect(HWND hwnd, RECT* out);

// Converte o frame visual desejado no retângulo a passar ao SetWindowPos.
RECT ToWindowRect(HWND hwnd, const RECT& visual);

bool FrameMatches(const RECT& a, const RECT& b, int tolerance);

struct ApplyOptions {
  // Voltas do laço de convergência (apps com tamanho mínimo/sidebar clampam
  // a primeira tentativa).
  int attempts = 3;
  int tolerance = 2;
  // Levanta a janela na ordem Z (sem ativar/roubar o foco).
  bool raise = true;
  // Restaura a janela quando minimizada/maximizada.
  bool restore = true;
};

// Posiciona a janela de modo que o frame VISUAL fique em |visual|.
// Retorna true quando o frame convergiu dentro da tolerância.
bool ApplyVisualFrame(HWND hwnd, const RECT& visual, const ApplyOptions& opt);

}  // namespace window_geometry

#endif  // RUNNER_MANAGERS_WINDOW_GEOMETRY_H_
