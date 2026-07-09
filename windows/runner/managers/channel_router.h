#ifndef RUNNER_MANAGERS_CHANNEL_ROUTER_H_
#define RUNNER_MANAGERS_CHANNEL_ROUTER_H_

#include <flutter/binary_messenger.h>
#include <flutter/method_channel.h>
#include <flutter/standard_method_codec.h>

#include <memory>

#include <windows.h>

#include "monitor_manager.h"
#include "permission_manager.h"
#include "shortcut_manager.h"
#include "system_manager.h"
#include "window_manager.h"
#include "workspace_manager.h"

// Registra os MethodChannels/EventChannels Flutter ↔ Windows e roteia cada
// chamada ao manager responsável. Mantém o FlutterWindow livre de lógica.
class ChannelRouter {
 public:
  // |hwnd| é a janela do runner, usada por hotkeys e bandeja.
  void Register(flutter::BinaryMessenger* messenger, HWND hwnd);

  // Eventos encaminhados pelo runner (MessageHandler).
  void OnDisplayChange();
  void OnHotKey(int id);
  void OnTrayMessage(WPARAM wparam, LPARAM lparam);

 private:
  WindowManager window_manager_;
  MonitorManager monitor_manager_;
  PermissionManager permission_manager_;
  ShortcutManager shortcut_manager_;
  WorkspaceManager workspace_manager_;
  SystemManager system_manager_;

  std::unique_ptr<flutter::MethodChannel<flutter::EncodableValue>>
      windows_channel_;
  std::unique_ptr<flutter::MethodChannel<flutter::EncodableValue>>
      monitors_channel_;
  std::unique_ptr<flutter::MethodChannel<flutter::EncodableValue>>
      permissions_channel_;
  std::unique_ptr<flutter::MethodChannel<flutter::EncodableValue>>
      shortcuts_channel_;
  std::unique_ptr<flutter::MethodChannel<flutter::EncodableValue>>
      workspace_channel_;
  std::unique_ptr<flutter::MethodChannel<flutter::EncodableValue>>
      app_channel_;
};

#endif  // RUNNER_MANAGERS_CHANNEL_ROUTER_H_
