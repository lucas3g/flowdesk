#include "snap_manager.h"

#include <flutter/encodable_value.h>

#include <cstdlib>

#include "app_identity.h"
#include "window_geometry.h"

using flutter::EncodableList;
using flutter::EncodableMap;
using flutter::EncodableValue;

namespace {

constexpr wchar_t kOverlayClassName[] = L"FlowDeskSnapZonesOverlay";
// Cor-chave do overlay: tudo pintado nessa cor fica invisível.
constexpr COLORREF kTransparentKey = RGB(255, 0, 255);
// Realce das zonas (tom de azul próximo do accent do app).
constexpr COLORREF kZoneFill = RGB(70, 130, 220);
constexpr COLORREF kZoneBorder = RGB(90, 150, 240);

double DoubleArg(const EncodableMap& args, const char* key) {
  auto it = args.find(EncodableValue(key));
  if (it == args.end()) return 0.0;
  if (const auto* d = std::get_if<double>(&it->second)) return *d;
  if (const auto* i = std::get_if<int32_t>(&it->second)) return *i;
  if (const auto* l = std::get_if<int64_t>(&it->second)) return double(*l);
  return 0.0;
}

}  // namespace

SnapManager* SnapManager::instance_ = nullptr;

SnapManager::~SnapManager() {
  Disable();
  if (timer_active_ && runner_hwnd_) {
    KillTimer(runner_hwnd_, kTrackTimerId);
    timer_active_ = false;
  }
  if (overlay_) {
    DestroyWindow(overlay_);
    overlay_ = nullptr;
  }
  if (instance_ == this) instance_ = nullptr;
}

void SnapManager::HandleMethodCall(
    const flutter::MethodCall<EncodableValue>& call,
    std::unique_ptr<flutter::MethodResult<EncodableValue>> result) {
  const std::string& method = call.method_name();

  if (method == "setLayoutSnapRegions") {
    const auto* args = std::get_if<EncodableMap>(call.arguments());
    if (!args) {
      result->Error("invalid_arguments",
                    "Argumentos inválidos para setLayoutSnapRegions");
      return;
    }

    bool enabled = false;
    auto enabled_it = args->find(EncodableValue("enabled"));
    if (enabled_it != args->end()) {
      if (const auto* b = std::get_if<bool>(&enabled_it->second)) {
        enabled = *b;
      }
    }

    regions_.clear();
    auto regions_it = args->find(EncodableValue("regions"));
    if (regions_it != args->end()) {
      if (const auto* list = std::get_if<EncodableList>(&regions_it->second)) {
        for (const auto& entry : *list) {
          if (const auto* map = std::get_if<EncodableMap>(&entry)) {
            const LONG x = LONG(DoubleArg(*map, "x"));
            const LONG y = LONG(DoubleArg(*map, "y"));
            const LONG width = LONG(DoubleArg(*map, "width"));
            const LONG height = LONG(DoubleArg(*map, "height"));
            regions_.push_back(RECT{x, y, x + width, y + height});
          }
        }
      }
    }

    enabled_ = enabled && !regions_.empty();
    if (enabled_) {
      Enable();
    } else {
      Disable();
    }
    result->Success(EncodableValue(true));
    return;
  }

  if (method == "setSnapExcludedApps") {
    excluded_.clear();
    const auto* args = std::get_if<EncodableMap>(call.arguments());
    if (args) {
      auto apps_it = args->find(EncodableValue("apps"));
      if (apps_it != args->end()) {
        if (const auto* list = std::get_if<EncodableList>(&apps_it->second)) {
          for (const auto& entry : *list) {
            const auto* map = std::get_if<EncodableMap>(&entry);
            if (!map) continue;
            auto id_it = map->find(EncodableValue("bundleId"));
            if (id_it == map->end()) continue;
            const auto* id = std::get_if<std::string>(&id_it->second);
            if (!id) continue;
            int64_t window_id = 0;
            auto window_it = map->find(EncodableValue("windowId"));
            if (window_it != map->end()) {
              if (const auto* w32 = std::get_if<int32_t>(&window_it->second)) {
                window_id = *w32;
              } else if (const auto* w64 =
                             std::get_if<int64_t>(&window_it->second)) {
                window_id = *w64;
              }
            }
            excluded_.emplace_back(*id, window_id);
          }
        }
      }
    }
    result->Success(EncodableValue(true));
    return;
  }

  result->NotImplemented();
}

// ---- Ativação ---------------------------------------------------------------

void SnapManager::Enable() {
  instance_ = this;
  if (move_hook_) return;
  // OUTOFCONTEXT entrega o callback na thread que instalou o hook — a
  // platform thread, que é quem roda o message loop do runner.
  move_hook_ = SetWinEventHook(EVENT_SYSTEM_MOVESIZESTART,
                               EVENT_SYSTEM_MOVESIZEEND, nullptr,
                               &SnapManager::WinEventProc, 0, 0,
                               WINEVENT_OUTOFCONTEXT | WINEVENT_SKIPOWNPROCESS);
}

void SnapManager::Disable() {
  if (move_hook_) {
    UnhookWinEvent(move_hook_);
    move_hook_ = nullptr;
  }
  ResetDragState();
}

void CALLBACK SnapManager::WinEventProc(HWINEVENTHOOK, DWORD event, HWND hwnd,
                                        LONG id_object, LONG id_child, DWORD,
                                        DWORD) {
  if (!instance_ || !instance_->enabled_) return;
  // Só a janela em si interessa (não seus controles filhos).
  if (id_object != OBJID_WINDOW || id_child != CHILDID_SELF) return;
  if (!hwnd || GetAncestor(hwnd, GA_ROOT) != hwnd) return;

  if (event == EVENT_SYSTEM_MOVESIZESTART) {
    instance_->OnMoveSizeStart(hwnd);
  } else if (event == EVENT_SYSTEM_MOVESIZEEND) {
    instance_->OnMoveSizeEnd(hwnd);
  }
}

// ---- Exclusão por app/instância ---------------------------------------------

// A janela está excluída quando há uma entrada do app com windowId 0 (app
// inteiro) ou com o HWND exato desta janela.
bool SnapManager::IsExcluded(HWND hwnd, DWORD pid) const {
  if (excluded_.empty()) return false;

  const std::string app_id = WindowAppId(hwnd, pid);
  const int64_t window_id = static_cast<int64_t>(
      reinterpret_cast<intptr_t>(hwnd));

  for (const auto& [bundle_id, wanted_id] : excluded_) {
    if (bundle_id != app_id) continue;
    if (wanted_id == 0 || wanted_id == window_id) return true;
  }
  return false;
}

// ---- Ciclo do arrasto -------------------------------------------------------

int SnapManager::ZoneAt(POINT pt) const {
  for (size_t i = 0; i < regions_.size(); ++i) {
    if (PtInRect(&regions_[i], pt)) return int(i);
  }
  return -1;
}

void SnapManager::OnMoveSizeStart(HWND hwnd) {
  ResetDragState();
  if (!enabled_ || !runner_hwnd_) return;

  // Ignora janelas do próprio FlowDesk (incluindo o overlay).
  DWORD pid = 0;
  GetWindowThreadProcessId(hwnd, &pid);
  if (pid == GetCurrentProcessId()) return;

  // Apps/instâncias excluídos arrastam livres: nenhum overlay ou encaixe.
  if (IsExcluded(hwnd, pid)) return;

  if (!window_geometry::VisualRect(hwnd, &drag_start_rect_)) return;
  dragged_ = hwnd;

  // O overlay só aparece quando o arrasto se confirma (ver OnTrackTick).
  if (SetTimer(runner_hwnd_, kTrackTimerId, 25, nullptr) != 0) {
    timer_active_ = true;
  }
}

void SnapManager::OnTrackTick() {
  if (!dragged_ || !IsWindow(dragged_)) {
    ResetDragState();
    return;
  }

  // Confirma que é um arrasto (move) e não um redimensionamento: o
  // MOVESIZESTART cobre os dois casos, e mostrar as zonas durante um resize
  // seria enganoso.
  if (!window_moving_) {
    RECT current{};
    if (!window_geometry::VisualRect(dragged_, &current)) return;
    const LONG moved_x = labs(current.left - drag_start_rect_.left);
    const LONG moved_y = labs(current.top - drag_start_rect_.top);
    const LONG resized_x =
        labs((current.right - current.left) -
             (drag_start_rect_.right - drag_start_rect_.left));
    const LONG resized_y =
        labs((current.bottom - current.top) -
             (drag_start_rect_.bottom - drag_start_rect_.top));
    if (resized_x > 2 || resized_y > 2) {
      // É resize: não participa do encaixe.
      ResetDragState();
      return;
    }
    if (moved_x <= 4 && moved_y <= 4) return;
    window_moving_ = true;
    ShowZones();
  }

  POINT pt{};
  if (!GetCursorPos(&pt)) return;
  const int hovered = ZoneAt(pt);
  if (hovered != suggested_index_) {
    suggested_index_ = hovered;
    if (overlay_) InvalidateRect(overlay_, nullptr, TRUE);
  }
}

void SnapManager::OnMoveSizeEnd(HWND hwnd) {
  if (hwnd != dragged_ || !window_moving_) {
    ResetDragState();
    return;
  }

  // A posição do cursor agora é autoritativa (o último tick pode estar
  // defasado em até 25ms).
  POINT pt{};
  const int index = GetCursorPos(&pt) ? ZoneAt(pt) : suggested_index_;

  if (index >= 0 && index < int(regions_.size())) {
    window_geometry::ApplyOptions options;
    options.attempts = 3;
    options.tolerance = 2;
    options.raise = true;
    options.restore = true;
    window_geometry::ApplyVisualFrame(hwnd, regions_[size_t(index)], options);
  }
  ResetDragState();
}

void SnapManager::ResetDragState() {
  if (timer_active_ && runner_hwnd_) {
    KillTimer(runner_hwnd_, kTrackTimerId);
    timer_active_ = false;
  }
  dragged_ = nullptr;
  window_moving_ = false;
  suggested_index_ = -1;
  HideZones();
}

// ---- Overlay ----------------------------------------------------------------

void SnapManager::ShowZones() {
  if (!overlay_class_registered_) {
    WNDCLASSW wc{};
    wc.lpfnWndProc = OverlayWndProc;
    wc.hInstance = GetModuleHandleW(nullptr);
    wc.lpszClassName = kOverlayClassName;
    wc.hCursor = LoadCursorW(nullptr, IDC_ARROW);
    RegisterClassW(&wc);
    overlay_class_registered_ = true;
  }

  const int x = GetSystemMetrics(SM_XVIRTUALSCREEN);
  const int y = GetSystemMetrics(SM_YVIRTUALSCREEN);
  const int width = GetSystemMetrics(SM_CXVIRTUALSCREEN);
  const int height = GetSystemMetrics(SM_CYVIRTUALSCREEN);

  if (!overlay_) {
    overlay_ = CreateWindowExW(
        WS_EX_LAYERED | WS_EX_TRANSPARENT | WS_EX_TOPMOST | WS_EX_TOOLWINDOW |
            WS_EX_NOACTIVATE,
        kOverlayClassName, L"", WS_POPUP, x, y, width, height, nullptr,
        nullptr, GetModuleHandleW(nullptr), nullptr);
    if (!overlay_) return;
    // Cor-chave transparente + alpha uniforme para o realce suave.
    SetLayeredWindowAttributes(overlay_, kTransparentKey, 110,
                               LWA_COLORKEY | LWA_ALPHA);
  } else {
    SetWindowPos(overlay_, HWND_TOPMOST, x, y, width, height,
                 SWP_NOACTIVATE);
  }

  ShowWindow(overlay_, SW_SHOWNOACTIVATE);
  InvalidateRect(overlay_, nullptr, TRUE);
}

void SnapManager::HideZones() {
  if (overlay_) ShowWindow(overlay_, SW_HIDE);
}

LRESULT CALLBACK SnapManager::OverlayWndProc(HWND hwnd, UINT message,
                                             WPARAM wparam, LPARAM lparam) {
  if (message == WM_DPICHANGED) {
    // O overlay cobre a área de trabalho virtual inteira; aceitar o retângulo
    // sugerido pelo sistema ao cruzar monitores de DPIs diferentes o
    // deformaria. Reafirma o tamanho correto.
    if (instance_) instance_->ShowZones();
    return 0;
  }
  if (message == WM_PAINT && instance_) {
    PAINTSTRUCT ps{};
    HDC hdc = BeginPaint(hwnd, &ps);
    instance_->PaintZones(hdc);
    EndPaint(hwnd, &ps);
    return 0;
  }
  return DefWindowProcW(hwnd, message, wparam, lparam);
}

void SnapManager::PaintZones(HDC hdc) {
  RECT client{};
  GetClientRect(overlay_, &client);

  // Fundo na cor-chave (invisível).
  HBRUSH background = CreateSolidBrush(kTransparentKey);
  FillRect(hdc, &client, background);
  DeleteObject(background);

  // O overlay cobre a área de trabalho virtual; as zonas estão em
  // coordenadas absolutas — converte para coordenadas do cliente.
  const int offset_x = GetSystemMetrics(SM_XVIRTUALSCREEN);
  const int offset_y = GetSystemMetrics(SM_YVIRTUALSCREEN);

  HBRUSH zone_fill = CreateSolidBrush(kZoneFill);
  HBRUSH zone_border = CreateSolidBrush(kZoneBorder);

  for (size_t i = 0; i < regions_.size(); ++i) {
    RECT zone = regions_[i];
    OffsetRect(&zone, -offset_x, -offset_y);
    InflateRect(&zone, -4, -4);

    if (int(i) == suggested_index_) {
      // Zona sob o cursor: preenchimento cheio.
      FillRect(hdc, &zone, zone_fill);
    }
    // Contorno de 2px em todas as zonas.
    for (int stroke = 0; stroke < 2; ++stroke) {
      FrameRect(hdc, &zone, zone_border);
      InflateRect(&zone, -1, -1);
    }
  }

  DeleteObject(zone_fill);
  DeleteObject(zone_border);
}
