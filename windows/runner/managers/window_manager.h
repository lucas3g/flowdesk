#ifndef RUNNER_MANAGERS_WINDOW_MANAGER_H_
#define RUNNER_MANAGERS_WINDOW_MANAGER_H_

#include <flutter/method_channel.h>
#include <flutter/standard_method_codec.h>
#include <windows.h>

#include <memory>

// Lista as janelas de topo (EnumWindows) e as manipula via Win32
// (SetWindowPos/ShowWindow/SetForegroundWindow). Espelha o WindowManager
// do macOS, com o HWND fazendo o papel do CGWindowID.
class WindowManager {
 public:
  WindowManager();
  ~WindowManager();

  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue>& call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

 private:
  flutter::EncodableValue WindowsPayload();
  bool SetWindowFrame(HWND hwnd, int x, int y, int width, int height);
  bool FocusWindow(HWND hwnd);

  ULONG_PTR gdiplus_token_ = 0;
};

#endif  // RUNNER_MANAGERS_WINDOW_MANAGER_H_
