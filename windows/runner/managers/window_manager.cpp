#include "window_manager.h"

#include <algorithm>

// O projeto compila com NOMINMAX; o GDI+ usa Gdiplus::min/max, então os
// reintroduzimos a partir do std antes de incluir os headers dele.
namespace Gdiplus {
using std::max;
using std::min;
}  // namespace Gdiplus

#include <dwmapi.h>
#include <objidl.h>
#include <gdiplus.h>
#include <propkey.h>
#include <psapi.h>
#include <shellapi.h>
#include <shlobj.h>

#include <string>
#include <vector>

#include "app_identity.h"
#include "string_utils.h"
#include "window_geometry.h"

using flutter::EncodableList;
using flutter::EncodableMap;
using flutter::EncodableValue;

namespace {

// Identificação do app (ProcessImagePath/BaseName/WindowAumid) vive em
// app_identity.h, compartilhada com o SnapManager.

// ---- Ícone (HICON → PNG via GDI+) -----------------------------------------

int PngEncoderClsid(CLSID* clsid) {
  UINT num = 0;
  UINT size = 0;
  Gdiplus::GetImageEncodersSize(&num, &size);
  if (size == 0) {
    return -1;
  }
  std::vector<BYTE> buffer(size);
  auto* encoders = reinterpret_cast<Gdiplus::ImageCodecInfo*>(buffer.data());
  Gdiplus::GetImageEncoders(num, size, encoders);
  for (UINT i = 0; i < num; ++i) {
    if (wcscmp(encoders[i].MimeType, L"image/png") == 0) {
      *clsid = encoders[i].Clsid;
      return static_cast<int>(i);
    }
  }
  return -1;
}

std::vector<uint8_t> IconPng(HWND hwnd, DWORD pid) {
  // Fonte do ícone: mensagem da janela, depois a classe, depois o exe.
  HICON icon = reinterpret_cast<HICON>(
      SendMessageW(hwnd, WM_GETICON, ICON_BIG, 0));
  if (!icon) {
    icon = reinterpret_cast<HICON>(GetClassLongPtrW(hwnd, GCLP_HICON));
  }
  HICON extracted = nullptr;
  if (!icon) {
    std::wstring path = ProcessImagePath(pid);
    if (!path.empty()) {
      ExtractIconExW(path.c_str(), 0, &extracted, nullptr, 1);
      icon = extracted;
    }
  }
  if (!icon) {
    return {};
  }

  std::vector<uint8_t> bytes;
  {
    Gdiplus::Bitmap bitmap(icon);
    CLSID clsid;
    if (PngEncoderClsid(&clsid) >= 0) {
      IStream* stream = nullptr;
      if (SUCCEEDED(CreateStreamOnHGlobal(nullptr, TRUE, &stream))) {
        if (bitmap.Save(stream, &clsid, nullptr) == Gdiplus::Ok) {
          HGLOBAL global = nullptr;
          GetHGlobalFromStream(stream, &global);
          if (global) {
            SIZE_T len = GlobalSize(global);
            void* data = GlobalLock(global);
            if (data && len > 0) {
              bytes.assign(static_cast<uint8_t*>(data),
                           static_cast<uint8_t*>(data) + len);
            }
            GlobalUnlock(global);
          }
        }
        stream->Release();
      }
    }
  }
  if (extracted) {
    DestroyIcon(extracted);
  }
  return bytes;
}

// Traz a janela para o primeiro plano contornando a restrição do Windows a
// SetForegroundWindow. Usado apenas por focusWindow: posicionar uma janela
// não deve roubar o foco (aplicar um layout faria isso em cascata).
//
// Detalhe do truque: anexa temporariamente a fila de input da thread que
// está em foreground à thread-alvo, "herdando" o direito de focar.
void ForceForeground(HWND hwnd) {
  HWND foreground = GetForegroundWindow();
  if (foreground == hwnd) {
    return;
  }

  DWORD target_thread = GetWindowThreadProcessId(hwnd, nullptr);
  DWORD foreground_thread =
      foreground ? GetWindowThreadProcessId(foreground, nullptr) : 0;
  DWORD current_thread = GetCurrentThreadId();

  // Reduz o timeout de foreground-lock para 0 para permitir a troca.
  DWORD lock_timeout = 0;
  SystemParametersInfoW(SPI_GETFOREGROUNDLOCKTIMEOUT, 0, &lock_timeout, 0);
  SystemParametersInfoW(SPI_SETFOREGROUNDLOCKTIMEOUT, 0,
                        reinterpret_cast<PVOID>(0), SPIF_SENDCHANGE);

  bool attached_foreground = false;
  bool attached_target = false;
  if (foreground_thread && foreground_thread != current_thread) {
    attached_foreground =
        AttachThreadInput(current_thread, foreground_thread, TRUE) != 0;
  }
  if (target_thread && target_thread != current_thread &&
      target_thread != foreground_thread) {
    attached_target =
        AttachThreadInput(current_thread, target_thread, TRUE) != 0;
  }

  BringWindowToTop(hwnd);
  SetForegroundWindow(hwnd);
  SetFocus(hwnd);

  if (attached_target) {
    AttachThreadInput(current_thread, target_thread, FALSE);
  }
  if (attached_foreground) {
    AttachThreadInput(current_thread, foreground_thread, FALSE);
  }

  // Restaura o timeout original.
  SystemParametersInfoW(SPI_SETFOREGROUNDLOCKTIMEOUT, 0,
                        reinterpret_cast<PVOID>(static_cast<UINT_PTR>(
                            lock_timeout)),
                        SPIF_SENDCHANGE);
}

// ---- Enumeração ------------------------------------------------------------

bool IsCloaked(HWND hwnd) {
  int cloaked = 0;
  DwmGetWindowAttribute(hwnd, DWMWA_CLOAKED, &cloaked, sizeof(cloaked));
  return cloaked != 0;
}

// Janela "real" de alt-tab: visível, com título, não tool window, não
// filha/owned, e não oculta pelo DWM (janelas UWP fantasmas).
bool IsManageableWindow(HWND hwnd) {
  if (!IsWindowVisible(hwnd)) {
    return false;
  }
  if (GetWindow(hwnd, GW_OWNER) != nullptr) {
    return false;
  }
  LONG ex_style = GetWindowLongW(hwnd, GWL_EXSTYLE);
  if (ex_style & WS_EX_TOOLWINDOW) {
    return false;
  }
  if (GetWindowTextLengthW(hwnd) == 0) {
    return false;
  }
  if (IsCloaked(hwnd)) {
    return false;
  }
  return true;
}

struct EnumContext {
  EncodableList* list;
  DWORD own_pid;
  HWND foreground;
};

BOOL CALLBACK EnumProc(HWND hwnd, LPARAM param) {
  auto* ctx = reinterpret_cast<EnumContext*>(param);
  if (!IsManageableWindow(hwnd)) {
    return TRUE;
  }

  DWORD pid = 0;
  GetWindowThreadProcessId(hwnd, &pid);
  if (pid == ctx->own_pid) {
    return TRUE;
  }

  RECT rect = {};
  const bool minimized = IsIconic(hwnd) != 0;
  if (minimized) {
    // Minimizada, GetWindowRect devolve -32000: usa a posição restaurada.
    // rcNormalPosition é uma aproximação (coordenadas de área de trabalho),
    // suficiente para saber em que monitor/região a janela estava.
    WINDOWPLACEMENT placement = {};
    placement.length = sizeof(placement);
    if (!GetWindowPlacement(hwnd, &placement)) {
      return TRUE;
    }
    rect = placement.rcNormalPosition;
  } else if (!window_geometry::VisualRect(hwnd, &rect)) {
    return TRUE;
  }

  int length = GetWindowTextLengthW(hwnd);
  std::wstring title(length, L'\0');
  if (length > 0) {
    GetWindowTextW(hwnd, title.data(), length + 1);
  }

  std::wstring image = ProcessImagePath(pid);
  std::string app_name = BaseName(image);
  std::string aumid = WindowAumid(hwnd);
  // AUMID quando disponível; senão o nome do executável como id estável.
  std::string bundle_id = aumid.empty() ? app_name : aumid;

  HMONITOR monitor = MonitorFromWindow(hwnd, MONITOR_DEFAULTTONEAREST);

  std::vector<uint8_t> icon = IconPng(hwnd, pid);

  ctx->list->push_back(EncodableValue(EncodableMap{
      {EncodableValue("id"),
       EncodableValue(reinterpret_cast<int64_t>(hwnd))},
      {EncodableValue("pid"), EncodableValue(static_cast<int64_t>(pid))},
      {EncodableValue("appName"), EncodableValue(app_name)},
      {EncodableValue("bundleId"), EncodableValue(bundle_id)},
      {EncodableValue("title"), EncodableValue(Utf8FromUtf16(title))},
      {EncodableValue("x"), EncodableValue(static_cast<double>(rect.left))},
      {EncodableValue("y"), EncodableValue(static_cast<double>(rect.top))},
      {EncodableValue("width"),
       EncodableValue(static_cast<double>(rect.right - rect.left))},
      {EncodableValue("height"),
       EncodableValue(static_cast<double>(rect.bottom - rect.top))},
      {EncodableValue("monitorId"),
       EncodableValue(reinterpret_cast<int64_t>(monitor))},
      {EncodableValue("isFocused"), EncodableValue(hwnd == ctx->foreground)},
      {EncodableValue("isMinimized"), EncodableValue(minimized)},
      {EncodableValue("icon"), EncodableValue(icon)},
  }));
  return TRUE;
}

}  // namespace

WindowManager::WindowManager() {
  Gdiplus::GdiplusStartupInput input;
  Gdiplus::GdiplusStartup(&gdiplus_token_, &input, nullptr);
}

WindowManager::~WindowManager() {
  if (timer_active_ && runner_hwnd_) {
    KillTimer(runner_hwnd_, kSettleTimerId);
    timer_active_ = false;
  }
  if (gdiplus_token_) {
    Gdiplus::GdiplusShutdown(gdiplus_token_);
  }
}

EncodableValue WindowManager::WindowsPayload() {
  EncodableList list;
  EnumContext ctx{&list, GetCurrentProcessId(), GetForegroundWindow()};
  EnumWindows(EnumProc, reinterpret_cast<LPARAM>(&ctx));
  return EncodableValue(list);
}

bool WindowManager::SetWindowFrame(HWND hwnd, int x, int y, int width,
                                   int height, bool settle) {
  if (!IsWindow(hwnd)) {
    return false;
  }
  const RECT visual{x, y, x + width, y + height};

  // Um settle de um posicionamento anterior puxaria a janela de volta: os
  // fluxos interativos (encaixe por teclado, ciclo entre regiões) mandam
  // settle=false justamente contando com isso.
  CancelPending(hwnd);

  // Levanta na ordem Z sem ativar: aplicar um layout inteiro com
  // ForceForeground roubava o foco janela a janela (e mexer na fila de input
  // do app durante o relayout aumenta a chance de ele clampar o tamanho).
  window_geometry::ApplyOptions options;
  options.attempts = 3;
  options.tolerance = 2;
  options.raise = true;
  options.restore = true;
  const bool ok = window_geometry::ApplyVisualFrame(hwnd, visual, options);

  if (settle) {
    SchedulePending(hwnd, visual);
  }
  return ok;
}

// ---- Reaplicações (settle) --------------------------------------------------

void WindowManager::SchedulePending(HWND hwnd, const RECT& visual) {
  if (!runner_hwnd_) {
    return;
  }
  const ULONGLONG now = GetTickCount64();
  PendingFrame pending;
  pending.hwnd = hwnd;
  pending.visual = visual;
  // Mesmos instantes do macOS (WindowManager.swift): 0,25s / 0,6s / 1,2s.
  pending.deadlines[0] = now + 250;
  pending.deadlines[1] = now + 600;
  pending.deadlines[2] = now + 1200;
  pending_.push_back(pending);
  EnsureTimer();
}

void WindowManager::CancelPending(HWND hwnd) {
  pending_.erase(std::remove_if(pending_.begin(), pending_.end(),
                                [hwnd](const PendingFrame& pending) {
                                  return pending.hwnd == hwnd;
                                }),
                 pending_.end());
}

void WindowManager::EnsureTimer() {
  if (timer_active_ || pending_.empty() || !runner_hwnd_) {
    return;
  }
  // Um único timer repetitivo enquanto houver pendências.
  if (SetTimer(runner_hwnd_, kSettleTimerId, 50, nullptr) != 0) {
    timer_active_ = true;
  }
}

void WindowManager::OnSettleTick() {
  const ULONGLONG now = GetTickCount64();

  for (auto& pending : pending_) {
    if (!IsWindow(pending.hwnd)) {
      pending.next = 3;
      continue;
    }
    while (pending.next < 3 && pending.deadlines[pending.next] <= now) {
      ++pending.next;
      RECT current = {};
      if (!window_geometry::VisualRect(pending.hwnd, &current)) {
        pending.next = 3;
        break;
      }
      if (window_geometry::FrameMatches(current, pending.visual, 2)) {
        continue;
      }
      // Correção tardia não levanta nem desminimiza: o usuário pode já ter
      // seguido para outra janela.
      window_geometry::ApplyOptions options;
      options.attempts = 2;
      options.tolerance = 2;
      options.raise = false;
      options.restore = false;
      window_geometry::ApplyVisualFrame(pending.hwnd, pending.visual, options);
    }
  }

  pending_.erase(std::remove_if(pending_.begin(), pending_.end(),
                                [](const PendingFrame& pending) {
                                  return pending.next >= 3;
                                }),
                 pending_.end());

  if (pending_.empty() && timer_active_) {
    KillTimer(runner_hwnd_, kSettleTimerId);
    timer_active_ = false;
  }
}

bool WindowManager::FocusWindow(HWND hwnd) {
  if (!IsWindow(hwnd)) {
    return false;
  }
  if (IsIconic(hwnd)) {
    ShowWindow(hwnd, SW_RESTORE);
  }
  ForceForeground(hwnd);
  return GetForegroundWindow() == hwnd;
}

void WindowManager::HandleMethodCall(
    const flutter::MethodCall<EncodableValue>& call,
    std::unique_ptr<flutter::MethodResult<EncodableValue>> result) {
  const std::string& method = call.method_name();

  if (method == "getWindows") {
    result->Success(WindowsPayload());
    return;
  }

  const auto* args = std::get_if<EncodableMap>(call.arguments());

  auto int_arg = [&](const char* key) -> int64_t {
    if (!args) return 0;
    auto it = args->find(EncodableValue(key));
    if (it == args->end()) return 0;
    if (const auto* v = std::get_if<int64_t>(&it->second)) return *v;
    if (const auto* v = std::get_if<int32_t>(&it->second)) return *v;
    if (const auto* v = std::get_if<double>(&it->second)) {
      return static_cast<int64_t>(*v);
    }
    return 0;
  };

  auto bool_arg = [&](const char* key, bool fallback) -> bool {
    if (!args) return fallback;
    auto it = args->find(EncodableValue(key));
    if (it == args->end()) return fallback;
    if (const auto* v = std::get_if<bool>(&it->second)) return *v;
    return fallback;
  };

  if (method == "setWindowFrame") {
    HWND hwnd = reinterpret_cast<HWND>(int_arg("id"));
    bool ok = SetWindowFrame(hwnd, static_cast<int>(int_arg("x")),
                             static_cast<int>(int_arg("y")),
                             static_cast<int>(int_arg("width")),
                             static_cast<int>(int_arg("height")),
                             bool_arg("settle", true));
    result->Success(EncodableValue(ok));
  } else if (method == "focusWindow") {
    HWND hwnd = reinterpret_cast<HWND>(int_arg("id"));
    result->Success(EncodableValue(FocusWindow(hwnd)));
  } else {
    result->NotImplemented();
  }
}
