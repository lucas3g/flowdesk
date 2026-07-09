#ifndef RUNNER_MANAGERS_SYSTEM_MANAGER_H_
#define RUNNER_MANAGERS_SYSTEM_MANAGER_H_

#include <flutter/event_channel.h>
#include <flutter/event_sink.h>
#include <flutter/method_channel.h>
#include <flutter/standard_method_codec.h>
#include <windows.h>

#include <cstdint>
#include <memory>
#include <string>
#include <vector>

// Canal flowdesk/app no Windows: ícone na bandeja (Shell_NotifyIcon) com
// menu dinâmico, iniciar com o Windows (Registry) e presença na barra de
// tarefas (equivalente ao "mostrar no Dock" do macOS).
class SystemManager {
 public:
  // Mensagem de callback do ícone da bandeja (encaminhada pelo runner).
  static constexpr UINT kTrayCallbackMessage = WM_APP + 1;

  ~SystemManager();

  void SetWindow(HWND hwnd) { hwnd_ = hwnd; }

  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue>& call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

  std::unique_ptr<flutter::StreamHandler<flutter::EncodableValue>>
  CreateStreamHandler();

  // Encaminhado pelo runner ao receber a mensagem do ícone da bandeja.
  void OnTrayMessage(WPARAM wparam, LPARAM lparam);

 private:
  struct MenuEntry {
    int64_t id;
    std::string title;
  };

  void SetLaunchAtLogin(bool enabled);
  void SetTrayVisible(bool visible);
  void SetTaskbarVisible(bool visible);
  void ShowMenu();
  void Emit(const std::string& type, int64_t id);

  HWND hwnd_ = nullptr;
  bool tray_added_ = false;
  std::vector<MenuEntry> layouts_;
  std::vector<MenuEntry> workspaces_;
  std::unique_ptr<flutter::EventSink<flutter::EncodableValue>> sink_;
};

#endif  // RUNNER_MANAGERS_SYSTEM_MANAGER_H_
