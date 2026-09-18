#include "window_geometry.h"

#include <dwmapi.h>

#include <cstdlib>

namespace window_geometry {

namespace {

// Limite de sanidade do padding: ~8px a 100% de DPI, ~24px a 300%. Acima
// disso o valor do DWM é considerado obsoleto (janela animando/oculta).
constexpr LONG kMaxPadding = 64;

}  // namespace

FramePadding PaddingOf(HWND hwnd) {
  if (!IsWindow(hwnd) || IsIconic(hwnd)) {
    return {};
  }

  RECT outer{};
  if (!GetWindowRect(hwnd, &outer)) {
    return {};
  }

  RECT frame{};
  if (FAILED(DwmGetWindowAttribute(hwnd, DWMWA_EXTENDED_FRAME_BOUNDS, &frame,
                                   sizeof(frame)))) {
    return {};
  }

  FramePadding padding{frame.left - outer.left, frame.top - outer.top,
                       outer.right - frame.right, outer.bottom - frame.bottom};

  // Janelas sem moldura devolvem zero; valores negativos ou absurdos indicam
  // bounds desatualizados — em ambos os casos, não compensa nada.
  if (padding.left < 0 || padding.top < 0 || padding.right < 0 ||
      padding.bottom < 0) {
    return {};
  }
  if (padding.left > kMaxPadding || padding.top > kMaxPadding ||
      padding.right > kMaxPadding || padding.bottom > kMaxPadding) {
    return {};
  }
  return padding;
}

bool VisualRect(HWND hwnd, RECT* out) {
  if (!out || !IsWindow(hwnd)) {
    return false;
  }
  RECT outer{};
  if (!GetWindowRect(hwnd, &outer)) {
    return false;
  }
  // Padding zero (DWM indisponível/implausível) devolve o retângulo externo.
  const FramePadding padding = PaddingOf(hwnd);
  *out = RECT{outer.left + padding.left, outer.top + padding.top,
              outer.right - padding.right, outer.bottom - padding.bottom};
  return true;
}

RECT ToWindowRect(HWND hwnd, const RECT& visual) {
  const FramePadding padding = PaddingOf(hwnd);
  return RECT{visual.left - padding.left, visual.top - padding.top,
              visual.right + padding.right, visual.bottom + padding.bottom};
}

bool FrameMatches(const RECT& a, const RECT& b, int tolerance) {
  return labs(a.left - b.left) <= tolerance &&
         labs(a.top - b.top) <= tolerance &&
         labs(a.right - b.right) <= tolerance &&
         labs(a.bottom - b.bottom) <= tolerance;
}

bool ApplyVisualFrame(HWND hwnd, const RECT& visual, const ApplyOptions& opt) {
  if (!IsWindow(hwnd)) {
    return false;
  }
  if (opt.restore && (IsIconic(hwnd) || IsZoomed(hwnd))) {
    ShowWindow(hwnd, SW_RESTORE);
  }

  HWND insert_after = opt.raise ? HWND_TOP : nullptr;
  // SWP_FRAMECHANGED de propósito fora: só é necessário depois de mudar
  // estilos e força um WM_NCCALCSIZE extra, que faz apps com layout reativo
  // (sidebars/drawers) clamparem o tamanho pedido.
  const UINT base_flags = SWP_NOACTIVATE | SWP_NOOWNERZORDER |
                          (opt.raise ? 0u : SWP_NOZORDER);

  for (int attempt = 0; attempt < opt.attempts; ++attempt) {
    // O padding é remedido a cada volta: ao mudar de monitor, o DPI (e com
    // ele a espessura da moldura) muda junto.
    const RECT target = ToWindowRect(hwnd, visual);
    const int width = static_cast<int>(target.right - target.left);
    const int height = static_cast<int>(target.bottom - target.top);

    if (attempt == 0) {
      if (!SetWindowPos(hwnd, insert_after, target.left, target.top, width,
                        height, base_flags) &&
          GetLastError() == ERROR_ACCESS_DENIED) {
        // Janela de processo elevado (UIPI): insistir não adianta.
        return false;
      }
    } else {
      // Mover antes de redimensionar: com a janela já no monitor de destino,
      // o tamanho deixa de ser clampado pela tela de origem.
      SetWindowPos(hwnd, nullptr, target.left, target.top, 0, 0,
                   base_flags | SWP_NOSIZE | SWP_NOZORDER);
      SetWindowPos(hwnd, nullptr, 0, 0, width, height,
                   base_flags | SWP_NOMOVE | SWP_NOZORDER);
    }

    RECT current{};
    if (!VisualRect(hwnd, &current)) {
      return false;
    }
    if (FrameMatches(current, visual, opt.tolerance)) {
      return true;
    }
  }
  return false;
}

}  // namespace window_geometry
