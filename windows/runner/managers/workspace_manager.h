#ifndef RUNNER_MANAGERS_WORKSPACE_MANAGER_H_
#define RUNNER_MANAGERS_WORKSPACE_MANAGER_H_

#include <flutter/event_channel.h>
#include <flutter/event_sink.h>
#include <flutter/method_channel.h>
#include <flutter/standard_method_codec.h>
#include <windows.h>

#include <memory>
#include <string>

// Lança aplicativos (por AUMID ou executável) e observa a abertura de novas
// janelas (SetWinEventHook), notificando o Flutter — base do rules engine e
// do Auto Restore, espelhando o didLaunchApplication do macOS.
class WorkspaceManager {
 public:
  WorkspaceManager();
  ~WorkspaceManager();

  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue>& call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

  std::unique_ptr<flutter::StreamHandler<flutter::EncodableValue>>
  CreateStreamHandler();

  // Chamado pelo hook global quando uma janela de app aparece. window_id é o
  // HWND da janela (mesmo id usado por getWindows) e pid o processo dono.
  void EmitAppLaunched(const std::string& bundle_id,
                       const std::string& app_name, int64_t window_id,
                       int64_t pid);

 private:
  bool LaunchApp(const std::string& bundle_id);
  bool IsAppRunning(const std::string& bundle_id);
  void EnsureHook();

  std::unique_ptr<flutter::EventSink<flutter::EncodableValue>> sink_;
  HWINEVENTHOOK hook_ = nullptr;
};

#endif  // RUNNER_MANAGERS_WORKSPACE_MANAGER_H_
