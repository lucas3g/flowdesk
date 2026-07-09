#include "monitor_manager.h"

#include <shellscalingapi.h>

#include <functional>
#include <string>
#include <vector>

#include "string_utils.h"

using flutter::EncodableList;
using flutter::EncodableMap;
using flutter::EncodableValue;

namespace {

// Escala (DPI) do monitor; 1.0 quando indisponível.
double MonitorScale(HMONITOR monitor) {
  UINT dpi_x = 96;
  UINT dpi_y = 96;
  if (GetDpiForMonitor(monitor, MDT_EFFECTIVE_DPI, &dpi_x, &dpi_y) == S_OK) {
    return static_cast<double>(dpi_x) / 96.0;
  }
  return 1.0;
}

// Taxa de atualização (Hz) do dispositivo do monitor.
double MonitorRefreshRate(const MONITORINFOEXW& info) {
  DEVMODEW mode = {};
  mode.dmSize = sizeof(DEVMODEW);
  if (EnumDisplaySettingsW(info.szDevice, ENUM_CURRENT_SETTINGS, &mode)) {
    return static_cast<double>(mode.dmDisplayFrequency);
  }
  return 0.0;
}

// Nome amigável do monitor (fallback para o nome do dispositivo).
std::string MonitorName(const MONITORINFOEXW& info) {
  DISPLAY_DEVICEW device = {};
  device.cb = sizeof(DISPLAY_DEVICEW);
  if (EnumDisplayDevicesW(info.szDevice, 0, &device, 0) &&
      device.DeviceString[0] != L'\0') {
    return Utf8FromUtf16(device.DeviceString);
  }
  return Utf8FromUtf16(info.szDevice);
}

BOOL CALLBACK EnumProc(HMONITOR monitor, HDC, LPRECT, LPARAM data) {
  auto* list = reinterpret_cast<EncodableList*>(data);

  MONITORINFOEXW info = {};
  info.cbSize = sizeof(MONITORINFOEXW);
  if (!GetMonitorInfoW(monitor, &info)) {
    return TRUE;
  }

  const RECT& r = info.rcMonitor;
  const RECT& work = info.rcWork;
  const bool is_primary = (info.dwFlags & MONITORINFOF_PRIMARY) != 0;
  const double scale = MonitorScale(monitor);

  // HMONITOR como id estável durante a sessão — o mesmo usado pelo
  // WindowManager (MonitorFromWindow) para casar janela ↔ monitor.
  const int64_t id = reinterpret_cast<int64_t>(monitor);

  list->push_back(EncodableValue(EncodableMap{
      {EncodableValue("id"), EncodableValue(id)},
      {EncodableValue("name"), EncodableValue(MonitorName(info))},
      {EncodableValue("x"), EncodableValue(static_cast<double>(r.left))},
      {EncodableValue("y"), EncodableValue(static_cast<double>(r.top))},
      {EncodableValue("width"),
       EncodableValue(static_cast<double>(r.right - r.left))},
      {EncodableValue("height"),
       EncodableValue(static_cast<double>(r.bottom - r.top))},
      {EncodableValue("visibleX"),
       EncodableValue(static_cast<double>(work.left))},
      {EncodableValue("visibleY"),
       EncodableValue(static_cast<double>(work.top))},
      {EncodableValue("visibleWidth"),
       EncodableValue(static_cast<double>(work.right - work.left))},
      {EncodableValue("visibleHeight"),
       EncodableValue(static_cast<double>(work.bottom - work.top))},
      {EncodableValue("pixelWidth"), EncodableValue(r.right - r.left)},
      {EncodableValue("pixelHeight"), EncodableValue(r.bottom - r.top)},
      {EncodableValue("scale"), EncodableValue(scale)},
      {EncodableValue("refreshRate"),
       EncodableValue(MonitorRefreshRate(info))},
      {EncodableValue("isPrimary"), EncodableValue(is_primary)},
      {EncodableValue("isBuiltIn"), EncodableValue(false)},
  }));
  return TRUE;
}

// Handler que apenas repassa os callbacks ao MonitorManager.
class MonitorStreamHandler
    : public flutter::StreamHandler<flutter::EncodableValue> {
 public:
  explicit MonitorStreamHandler(MonitorManager* manager) : manager_(manager) {}

 protected:
  std::unique_ptr<flutter::StreamHandlerError<flutter::EncodableValue>>
  OnListenInternal(
      const flutter::EncodableValue*,
      std::unique_ptr<flutter::EventSink<flutter::EncodableValue>>&& events)
      override {
    on_listen_(std::move(events));
    return nullptr;
  }

  std::unique_ptr<flutter::StreamHandlerError<flutter::EncodableValue>>
  OnCancelInternal(const flutter::EncodableValue*) override {
    on_cancel_();
    return nullptr;
  }

 public:
  std::function<void(
      std::unique_ptr<flutter::EventSink<flutter::EncodableValue>>&&)>
      on_listen_;
  std::function<void()> on_cancel_;

 private:
  MonitorManager* manager_;
};

}  // namespace

EncodableValue MonitorManager::MonitorsPayload() {
  EncodableList list;
  EnumDisplayMonitors(nullptr, nullptr, EnumProc,
                      reinterpret_cast<LPARAM>(&list));
  return EncodableValue(list);
}

void MonitorManager::HandleMethodCall(
    const flutter::MethodCall<EncodableValue>& call,
    std::unique_ptr<flutter::MethodResult<EncodableValue>> result) {
  if (call.method_name() == "getMonitors") {
    result->Success(MonitorsPayload());
  } else {
    result->NotImplemented();
  }
}

std::unique_ptr<flutter::StreamHandler<EncodableValue>>
MonitorManager::CreateStreamHandler() {
  auto handler = std::make_unique<MonitorStreamHandler>(this);
  handler->on_listen_ =
      [this](std::unique_ptr<flutter::EventSink<EncodableValue>>&& events) {
        sink_ = std::move(events);
        // Emite o estado atual imediatamente ao assinar.
        sink_->Success(MonitorsPayload());
      };
  handler->on_cancel_ = [this]() { sink_.reset(); };
  return handler;
}

void MonitorManager::OnDisplayChange() {
  if (sink_) {
    sink_->Success(MonitorsPayload());
  }
}
