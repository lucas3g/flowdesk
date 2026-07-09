#include "system_manager.h"

#include <shellapi.h>

#include <cstring>
#include <functional>

#include "../resource.h"
#include "string_utils.h"

using flutter::EncodableList;
using flutter::EncodableMap;
using flutter::EncodableValue;

namespace {

constexpr wchar_t kRunKey[] =
    L"Software\\Microsoft\\Windows\\CurrentVersion\\Run";
constexpr wchar_t kRunValue[] = L"FlowDesk";

// Faixas de command id do menu da bandeja.
constexpr UINT kCmdOpen = 1;
constexpr UINT kCmdPreferences = 2;
constexpr UINT kCmdQuit = 3;
constexpr UINT kCmdLayoutBase = 1000;
constexpr UINT kCmdWorkspaceBase = 2000;

std::wstring ExecutablePath() {
  wchar_t buffer[MAX_PATH] = {};
  GetModuleFileNameW(nullptr, buffer, MAX_PATH);
  return std::wstring(buffer);
}

std::wstring Utf16FromUtf8(const std::string& utf8) {
  if (utf8.empty()) return L"";
  int size = MultiByteToWideChar(CP_UTF8, 0, utf8.data(),
                                 static_cast<int>(utf8.size()), nullptr, 0);
  std::wstring utf16(size, 0);
  MultiByteToWideChar(CP_UTF8, 0, utf8.data(), static_cast<int>(utf8.size()),
                      utf16.data(), size);
  return utf16;
}

bool BoolArg(const EncodableMap& map, const char* key, bool fallback) {
  auto it = map.find(EncodableValue(key));
  if (it == map.end()) return fallback;
  if (const auto* v = std::get_if<bool>(&it->second)) return *v;
  return fallback;
}

int64_t IntArg(const EncodableMap& map, const char* key) {
  auto it = map.find(EncodableValue(key));
  if (it == map.end()) return 0;
  if (const auto* v = std::get_if<int64_t>(&it->second)) return *v;
  if (const auto* v = std::get_if<int32_t>(&it->second)) return *v;
  return 0;
}

std::string StringArg(const EncodableMap& map, const char* key) {
  auto it = map.find(EncodableValue(key));
  if (it == map.end()) return "";
  if (const auto* v = std::get_if<std::string>(&it->second)) return *v;
  return "";
}

class ForwardingStreamHandler
    : public flutter::StreamHandler<flutter::EncodableValue> {
 public:
  std::function<void(
      std::unique_ptr<flutter::EventSink<flutter::EncodableValue>>&&)>
      on_listen;
  std::function<void()> on_cancel;

 protected:
  std::unique_ptr<flutter::StreamHandlerError<flutter::EncodableValue>>
  OnListenInternal(
      const flutter::EncodableValue*,
      std::unique_ptr<flutter::EventSink<flutter::EncodableValue>>&& events)
      override {
    on_listen(std::move(events));
    return nullptr;
  }
  std::unique_ptr<flutter::StreamHandlerError<flutter::EncodableValue>>
  OnCancelInternal(const flutter::EncodableValue*) override {
    if (on_cancel) on_cancel();
    return nullptr;
  }
};

}  // namespace

SystemManager::~SystemManager() {
  if (tray_added_) {
    SetTrayVisible(false);
  }
}

void SystemManager::SetLaunchAtLogin(bool enabled) {
  HKEY key = nullptr;
  if (RegOpenKeyExW(HKEY_CURRENT_USER, kRunKey, 0, KEY_SET_VALUE, &key) !=
      ERROR_SUCCESS) {
    return;
  }
  if (enabled) {
    const std::wstring path = L"\"" + ExecutablePath() + L"\"";
    RegSetValueExW(
        key, kRunValue, 0, REG_SZ,
        reinterpret_cast<const BYTE*>(path.c_str()),
        static_cast<DWORD>((path.size() + 1) * sizeof(wchar_t)));
  } else {
    RegDeleteValueW(key, kRunValue);
  }
  RegCloseKey(key);
}

void SystemManager::SetTrayVisible(bool visible) {
  if (!hwnd_) return;

  NOTIFYICONDATAW nid = {};
  nid.cbSize = sizeof(nid);
  nid.hWnd = hwnd_;
  nid.uID = 1;

  if (visible) {
    if (tray_added_) return;
    nid.uFlags = NIF_ICON | NIF_MESSAGE | NIF_TIP;
    nid.uCallbackMessage = kTrayCallbackMessage;
    nid.hIcon = LoadIconW(GetModuleHandleW(nullptr),
                          MAKEINTRESOURCEW(IDI_APP_ICON));
    wcscpy_s(nid.szTip, L"FlowDesk");
    Shell_NotifyIconW(NIM_ADD, &nid);
    tray_added_ = true;
  } else {
    if (!tray_added_) return;
    Shell_NotifyIconW(NIM_DELETE, &nid);
    tray_added_ = false;
  }
}

void SystemManager::SetTaskbarVisible(bool visible) {
  if (!hwnd_) return;
  // Sem WS_EX_APPWINDOW/com WS_EX_TOOLWINDOW a janela some da barra de
  // tarefas. A troca exige esconder e reexibir a janela.
  LONG_PTR ex = GetWindowLongPtrW(hwnd_, GWL_EXSTYLE);
  ShowWindow(hwnd_, SW_HIDE);
  if (visible) {
    ex |= WS_EX_APPWINDOW;
    ex &= ~WS_EX_TOOLWINDOW;
  } else {
    ex |= WS_EX_TOOLWINDOW;
    ex &= ~WS_EX_APPWINDOW;
  }
  SetWindowLongPtrW(hwnd_, GWL_EXSTYLE, ex);
  ShowWindow(hwnd_, SW_SHOW);
}

void SystemManager::ShowMenu() {
  if (!hwnd_) return;

  HMENU menu = CreatePopupMenu();
  AppendMenuW(menu, MF_STRING, kCmdOpen, L"Abrir o FlowDesk");
  AppendMenuW(menu, MF_SEPARATOR, 0, nullptr);

  if (!layouts_.empty()) {
    HMENU sub = CreatePopupMenu();
    for (size_t i = 0; i < layouts_.size(); ++i) {
      AppendMenuW(sub, MF_STRING, kCmdLayoutBase + static_cast<UINT>(i),
                  Utf16FromUtf8(layouts_[i].title).c_str());
    }
    AppendMenuW(menu, MF_POPUP, reinterpret_cast<UINT_PTR>(sub), L"Layouts");
  }
  if (!workspaces_.empty()) {
    HMENU sub = CreatePopupMenu();
    for (size_t i = 0; i < workspaces_.size(); ++i) {
      AppendMenuW(sub, MF_STRING, kCmdWorkspaceBase + static_cast<UINT>(i),
                  Utf16FromUtf8(workspaces_[i].title).c_str());
    }
    AppendMenuW(menu, MF_POPUP, reinterpret_cast<UINT_PTR>(sub),
                L"Workspaces");
  }

  AppendMenuW(menu, MF_SEPARATOR, 0, nullptr);
  AppendMenuW(menu, MF_STRING, kCmdPreferences, L"Preferências…");
  AppendMenuW(menu, MF_STRING, kCmdQuit, L"Sair do FlowDesk");

  POINT cursor;
  GetCursorPos(&cursor);
  // Requisito do Win32 para o menu fechar ao clicar fora.
  SetForegroundWindow(hwnd_);
  UINT cmd = TrackPopupMenu(menu, TPM_RIGHTBUTTON | TPM_RETURNCMD, cursor.x,
                            cursor.y, 0, hwnd_, nullptr);
  DestroyMenu(menu);

  if (cmd == kCmdOpen) {
    Emit("openApp", 0);
  } else if (cmd == kCmdPreferences) {
    Emit("openPreferences", 0);
  } else if (cmd == kCmdQuit) {
    PostMessageW(hwnd_, WM_CLOSE, 0, 0);
  } else if (cmd >= kCmdLayoutBase && cmd < kCmdWorkspaceBase) {
    size_t index = cmd - kCmdLayoutBase;
    if (index < layouts_.size()) Emit("applyLayout", layouts_[index].id);
  } else if (cmd >= kCmdWorkspaceBase) {
    size_t index = cmd - kCmdWorkspaceBase;
    if (index < workspaces_.size()) {
      Emit("applyWorkspace", workspaces_[index].id);
    }
  }
}

void SystemManager::Emit(const std::string& type, int64_t id) {
  if (!sink_) return;
  sink_->Success(EncodableValue(EncodableMap{
      {EncodableValue("type"), EncodableValue(type)},
      {EncodableValue("id"), EncodableValue(id)},
  }));
}

void SystemManager::OnTrayMessage(WPARAM, LPARAM lparam) {
  const UINT event = LOWORD(lparam);
  if (event == WM_LBUTTONUP) {
    Emit("openApp", 0);
  } else if (event == WM_RBUTTONUP) {
    ShowMenu();
  }
}

void SystemManager::HandleMethodCall(
    const flutter::MethodCall<EncodableValue>& call,
    std::unique_ptr<flutter::MethodResult<EncodableValue>> result) {
  const std::string& method = call.method_name();
  const auto* args = std::get_if<EncodableMap>(call.arguments());

  if (method == "setLaunchAtLogin") {
    SetLaunchAtLogin(args && BoolArg(*args, "enabled", false));
    result->Success(EncodableValue(true));
  } else if (method == "setStatusBarVisible") {
    SetTrayVisible(!args || BoolArg(*args, "visible", true));
    result->Success();
  } else if (method == "setDockVisible") {
    SetTaskbarVisible(!args || BoolArg(*args, "visible", true));
    result->Success();
  } else if (method == "setStatusBarMenu") {
    layouts_.clear();
    workspaces_.clear();
    if (args) {
      auto layouts_it = args->find(EncodableValue("layouts"));
      if (layouts_it != args->end()) {
        if (const auto* list = std::get_if<EncodableList>(&layouts_it->second)) {
          for (const auto& e : *list) {
            if (const auto* m = std::get_if<EncodableMap>(&e)) {
              layouts_.push_back({IntArg(*m, "id"), StringArg(*m, "name")});
            }
          }
        }
      }
      auto ws_it = args->find(EncodableValue("workspaces"));
      if (ws_it != args->end()) {
        if (const auto* list = std::get_if<EncodableList>(&ws_it->second)) {
          for (const auto& e : *list) {
            if (const auto* m = std::get_if<EncodableMap>(&e)) {
              std::string emoji = StringArg(*m, "emoji");
              std::string name = StringArg(*m, "name");
              workspaces_.push_back(
                  {IntArg(*m, "id"), emoji.empty() ? name : emoji + " " + name});
            }
          }
        }
      }
    }
    result->Success();
  } else {
    result->NotImplemented();
  }
}

std::unique_ptr<flutter::StreamHandler<EncodableValue>>
SystemManager::CreateStreamHandler() {
  auto handler = std::make_unique<ForwardingStreamHandler>();
  handler->on_listen =
      [this](std::unique_ptr<flutter::EventSink<EncodableValue>>&& events) {
        sink_ = std::move(events);
      };
  handler->on_cancel = [this]() { sink_.reset(); };
  return handler;
}
