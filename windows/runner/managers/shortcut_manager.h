#ifndef RUNNER_MANAGERS_SHORTCUT_MANAGER_H_
#define RUNNER_MANAGERS_SHORTCUT_MANAGER_H_

#include <flutter/event_channel.h>
#include <flutter/event_sink.h>
#include <flutter/method_channel.h>
#include <flutter/standard_method_codec.h>
#include <windows.h>

#include <memory>
#include <vector>

// Hotkeys globais via Win32 (RegisterHotKey). O HWND do runner recebe os
// WM_HOTKEY, encaminhados pelo FlutterWindow ao ChannelRouter.
class ShortcutManager {
 public:
  void SetWindow(HWND hwnd) { hwnd_ = hwnd; }

  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue>& call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

  std::unique_ptr<flutter::StreamHandler<flutter::EncodableValue>>
  CreateStreamHandler();

  // Encaminhado pelo runner em WM_HOTKEY (wparam = id do atalho).
  void OnHotKey(int id);

 private:
  void UnregisterAll();

  HWND hwnd_ = nullptr;
  std::vector<int> registered_ids_;
  std::unique_ptr<flutter::EventSink<flutter::EncodableValue>> sink_;
};

#endif  // RUNNER_MANAGERS_SHORTCUT_MANAGER_H_
