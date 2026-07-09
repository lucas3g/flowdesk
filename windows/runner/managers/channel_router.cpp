#include "channel_router.h"

#include <flutter/event_channel.h>

using flutter::EncodableValue;
using MethodChannel = flutter::MethodChannel<EncodableValue>;
using EventChannel = flutter::EventChannel<EncodableValue>;

void ChannelRouter::Register(flutter::BinaryMessenger* messenger, HWND hwnd) {
  const auto& codec = flutter::StandardMethodCodec::GetInstance();

  shortcut_manager_.SetWindow(hwnd);
  system_manager_.SetWindow(hwnd);

  permissions_channel_ = std::make_unique<MethodChannel>(
      messenger, "flowdesk/permissions", &codec);
  permissions_channel_->SetMethodCallHandler(
      [this](const auto& call, auto result) {
        permission_manager_.HandleMethodCall(call, std::move(result));
      });

  windows_channel_ =
      std::make_unique<MethodChannel>(messenger, "flowdesk/windows", &codec);
  windows_channel_->SetMethodCallHandler(
      [this](const auto& call, auto result) {
        window_manager_.HandleMethodCall(call, std::move(result));
      });

  monitors_channel_ =
      std::make_unique<MethodChannel>(messenger, "flowdesk/monitors", &codec);
  monitors_channel_->SetMethodCallHandler(
      [this](const auto& call, auto result) {
        monitor_manager_.HandleMethodCall(call, std::move(result));
      });

  EventChannel monitors_events(messenger, "flowdesk/monitors/events", &codec);
  monitors_events.SetStreamHandler(monitor_manager_.CreateStreamHandler());

  shortcuts_channel_ =
      std::make_unique<MethodChannel>(messenger, "flowdesk/shortcuts", &codec);
  shortcuts_channel_->SetMethodCallHandler(
      [this](const auto& call, auto result) {
        shortcut_manager_.HandleMethodCall(call, std::move(result));
      });

  EventChannel shortcuts_events(messenger, "flowdesk/shortcuts/events", &codec);
  shortcuts_events.SetStreamHandler(shortcut_manager_.CreateStreamHandler());

  workspace_channel_ =
      std::make_unique<MethodChannel>(messenger, "flowdesk/workspace", &codec);
  workspace_channel_->SetMethodCallHandler(
      [this](const auto& call, auto result) {
        workspace_manager_.HandleMethodCall(call, std::move(result));
      });

  EventChannel workspace_events(messenger, "flowdesk/workspace/events", &codec);
  workspace_events.SetStreamHandler(workspace_manager_.CreateStreamHandler());

  // Canal do app: login (LaunchAtLogin) e bandeja/taskbar (SystemManager).
  app_channel_ =
      std::make_unique<MethodChannel>(messenger, "flowdesk/app", &codec);
  app_channel_->SetMethodCallHandler([this](const auto& call, auto result) {
    system_manager_.HandleMethodCall(call, std::move(result));
  });

  EventChannel app_events(messenger, "flowdesk/app/events", &codec);
  app_events.SetStreamHandler(system_manager_.CreateStreamHandler());
}

void ChannelRouter::OnDisplayChange() {
  monitor_manager_.OnDisplayChange();
}

void ChannelRouter::OnHotKey(int id) {
  shortcut_manager_.OnHotKey(id);
}

void ChannelRouter::OnTrayMessage(WPARAM wparam, LPARAM lparam) {
  system_manager_.OnTrayMessage(wparam, lparam);
}
