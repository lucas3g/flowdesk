#ifndef RUNNER_MANAGERS_MONITOR_MANAGER_H_
#define RUNNER_MANAGERS_MONITOR_MANAGER_H_

#include <flutter/event_channel.h>
#include <flutter/event_sink.h>
#include <flutter/method_channel.h>
#include <flutter/standard_method_codec.h>
#include <windows.h>

#include <memory>

// Enumera os monitores (EnumDisplayMonitors) e notifica o Flutter quando a
// configuração de telas muda (WM_DISPLAYCHANGE, encaminhado pelo runner).
class MonitorManager {
 public:
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue>& call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

  // StreamHandler do EventChannel de mudanças.
  std::unique_ptr<flutter::StreamHandler<flutter::EncodableValue>>
  CreateStreamHandler();

  // Chamado pelo runner ao receber WM_DISPLAYCHANGE.
  void OnDisplayChange();

  // Lista atual de monitores como payload do canal.
  flutter::EncodableValue MonitorsPayload();

 private:
  std::unique_ptr<flutter::EventSink<flutter::EncodableValue>> sink_;
};

#endif  // RUNNER_MANAGERS_MONITOR_MANAGER_H_
