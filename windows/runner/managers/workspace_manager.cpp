#include "workspace_manager.h"

#include <psapi.h>
#include <shellapi.h>
#include <tlhelp32.h>

#include <algorithm>
#include <cctype>
#include <functional>

#include "string_utils.h"

using flutter::EncodableList;
using flutter::EncodableMap;
using flutter::EncodableValue;

namespace {

// Instância única para o callback global do WinEventHook.
WorkspaceManager* g_instance = nullptr;

std::string StringArg(const EncodableMap& map, const char* key) {
  auto it = map.find(EncodableValue(key));
  if (it == map.end()) return "";
  if (const auto* v = std::get_if<std::string>(&it->second)) return *v;
  return "";
}

std::string LowerAscii(std::string value) {
  std::transform(value.begin(), value.end(), value.begin(), [](unsigned char c) {
    return static_cast<char>(std::tolower(c));
  });
  return value;
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

std::string ProcessExeName(DWORD pid) {
  HANDLE process = OpenProcess(PROCESS_QUERY_LIMITED_INFORMATION, FALSE, pid);
  if (!process) return "";
  wchar_t buffer[MAX_PATH] = {};
  DWORD size = MAX_PATH;
  std::string name;
  if (QueryFullProcessImageNameW(process, 0, buffer, &size)) {
    std::wstring path(buffer, size);
    size_t slash = path.find_last_of(L"\\/");
    name = Utf8FromUtf16(slash == std::wstring::npos ? path
                                                     : path.substr(slash + 1));
  }
  CloseHandle(process);
  return name;
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

// Callback global de EVENT_OBJECT_SHOW: filtra janelas de topo reais e
// notifica o WorkspaceManager.
void CALLBACK WinEventProc(HWINEVENTHOOK, DWORD event, HWND hwnd,
                           LONG id_object, LONG id_child, DWORD, DWORD) {
  if (!g_instance || event != EVENT_OBJECT_SHOW) return;
  if (id_object != OBJID_WINDOW || id_child != CHILDID_SELF || !hwnd) return;
  if (GetAncestor(hwnd, GA_ROOT) != hwnd) return;
  if (!IsWindowVisible(hwnd) || GetWindowTextLengthW(hwnd) == 0) return;
  if (GetWindow(hwnd, GW_OWNER) != nullptr) return;

  DWORD pid = 0;
  GetWindowThreadProcessId(hwnd, &pid);
  if (pid == 0 || pid == GetCurrentProcessId()) return;

  const std::string exe = ProcessExeName(pid);
  if (exe.empty()) return;
  g_instance->EmitAppLaunched(exe, exe);
}

}  // namespace

WorkspaceManager::WorkspaceManager() { g_instance = this; }

WorkspaceManager::~WorkspaceManager() {
  if (hook_) {
    UnhookWinEvent(hook_);
  }
  if (g_instance == this) {
    g_instance = nullptr;
  }
}

void WorkspaceManager::EnsureHook() {
  if (hook_) return;
  hook_ = SetWinEventHook(EVENT_OBJECT_SHOW, EVENT_OBJECT_SHOW, nullptr,
                          WinEventProc, 0, 0,
                          WINEVENT_OUTOFCONTEXT | WINEVENT_SKIPOWNPROCESS);
}

bool WorkspaceManager::LaunchApp(const std::string& bundle_id) {
  if (bundle_id.empty()) return false;
  const std::wstring wide = Utf16FromUtf8(bundle_id);

  // AUMIDs (sem extensão .exe) abrem via shell:AppsFolder.
  const bool looks_like_exe = LowerAscii(bundle_id).find(".exe") !=
                              std::string::npos;
  if (!looks_like_exe) {
    const std::wstring target = L"shell:AppsFolder\\" + wide;
    HINSTANCE r = ShellExecuteW(nullptr, L"open", target.c_str(), nullptr,
                                nullptr, SW_SHOWNORMAL);
    if (reinterpret_cast<INT_PTR>(r) > 32) return true;
  }

  // Fallback: executável (resolvido pelo App Paths do registro, se houver).
  HINSTANCE r = ShellExecuteW(nullptr, L"open", wide.c_str(), nullptr, nullptr,
                              SW_SHOWNORMAL);
  return reinterpret_cast<INT_PTR>(r) > 32;
}

bool WorkspaceManager::IsAppRunning(const std::string& bundle_id) {
  const std::string target = LowerAscii(bundle_id);
  HANDLE snapshot = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  if (snapshot == INVALID_HANDLE_VALUE) return false;

  PROCESSENTRY32W entry = {};
  entry.dwSize = sizeof(entry);
  bool found = false;
  if (Process32FirstW(snapshot, &entry)) {
    do {
      if (LowerAscii(Utf8FromUtf16(entry.szExeFile)) == target) {
        found = true;
        break;
      }
    } while (Process32NextW(snapshot, &entry));
  }
  CloseHandle(snapshot);
  return found;
}

void WorkspaceManager::HandleMethodCall(
    const flutter::MethodCall<EncodableValue>& call,
    std::unique_ptr<flutter::MethodResult<EncodableValue>> result) {
  const std::string& method = call.method_name();
  const auto* args = std::get_if<EncodableMap>(call.arguments());
  const std::string bundle_id = args ? StringArg(*args, "bundleId") : "";

  if (method == "launchApp") {
    result->Success(EncodableValue(LaunchApp(bundle_id)));
  } else if (method == "isAppRunning") {
    result->Success(EncodableValue(IsAppRunning(bundle_id)));
  } else {
    result->NotImplemented();
  }
}

std::unique_ptr<flutter::StreamHandler<EncodableValue>>
WorkspaceManager::CreateStreamHandler() {
  auto handler = std::make_unique<ForwardingStreamHandler>();
  handler->on_listen =
      [this](std::unique_ptr<flutter::EventSink<EncodableValue>>&& events) {
        sink_ = std::move(events);
        EnsureHook();
      };
  handler->on_cancel = [this]() { sink_.reset(); };
  return handler;
}

void WorkspaceManager::EmitAppLaunched(const std::string& bundle_id,
                                       const std::string& app_name) {
  if (!sink_) return;
  sink_->Success(EncodableValue(EncodableMap{
      {EncodableValue("bundleId"), EncodableValue(bundle_id)},
      {EncodableValue("appName"), EncodableValue(app_name)},
  }));
}
