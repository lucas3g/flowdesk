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
// SetForegroundWindow: anexa temporariamente a fila de input da thread que
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
  if (!GetWindowRect(hwnd, &rect)) {
    return TRUE;
  }
  const bool minimized = IsIconic(hwnd) != 0;

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
                                   int height) {
  if (!IsWindow(hwnd)) {
    return false;
  }
  // Restaura a janela se estiver minimizada/maximizada — não é possível
  // reposicionar uma janela minimizada.
  if (IsIconic(hwnd) || IsZoomed(hwnd)) {
    ShowWindow(hwnd, SW_RESTORE);
  }
  // Traz para frente (janelas atrás de outras precisam ser levantadas).
  ForceForeground(hwnd);

  return SetWindowPos(hwnd, HWND_TOP, x, y, width, height,
                      SWP_NOACTIVATE | SWP_FRAMECHANGED) != 0;
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

  if (method == "setWindowFrame") {
    HWND hwnd = reinterpret_cast<HWND>(int_arg("id"));
    bool ok = SetWindowFrame(hwnd, static_cast<int>(int_arg("x")),
                             static_cast<int>(int_arg("y")),
                             static_cast<int>(int_arg("width")),
                             static_cast<int>(int_arg("height")));
    result->Success(EncodableValue(ok));
  } else if (method == "focusWindow") {
    HWND hwnd = reinterpret_cast<HWND>(int_arg("id"));
    result->Success(EncodableValue(FocusWindow(hwnd)));
  } else {
    result->NotImplemented();
  }
}
