#include "shortcut_manager.h"

#include <functional>

using flutter::EncodableList;
using flutter::EncodableMap;
using flutter::EncodableValue;

namespace {

bool BoolArg(const EncodableMap& map, const char* key) {
  auto it = map.find(EncodableValue(key));
  if (it == map.end()) return false;
  if (const auto* v = std::get_if<bool>(&it->second)) return *v;
  return false;
}

int IntArg(const EncodableMap& map, const char* key) {
  auto it = map.find(EncodableValue(key));
  if (it == map.end()) return 0;
  if (const auto* v = std::get_if<int64_t>(&it->second)) {
    return static_cast<int>(*v);
  }
  if (const auto* v = std::get_if<int32_t>(&it->second)) return *v;
  return 0;
}

std::string StringArg(const EncodableMap& map, const char* key) {
  auto it = map.find(EncodableValue(key));
  if (it == map.end()) return "";
  if (const auto* v = std::get_if<std::string>(&it->second)) return *v;
  return "";
}

// Handler genérico de EventChannel que delega listen/cancel.
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

void ShortcutManager::UnregisterAll() {
  for (int id : registered_ids_) {
    UnregisterHotKey(hwnd_, id);
  }
  registered_ids_.clear();
}

void ShortcutManager::HandleMethodCall(
    const flutter::MethodCall<EncodableValue>& call,
    std::unique_ptr<flutter::MethodResult<EncodableValue>> result) {
  const std::string& method = call.method_name();

  if (method == "registerShortcuts") {
    UnregisterAll();
    const auto* args = std::get_if<EncodableMap>(call.arguments());
    if (args && hwnd_) {
      auto it = args->find(EncodableValue("shortcuts"));
      if (it != args->end()) {
        if (const auto* list = std::get_if<EncodableList>(&it->second)) {
          for (const auto& entry : *list) {
            const auto* map = std::get_if<EncodableMap>(&entry);
            if (!map) continue;

            const int id = IntArg(*map, "id");
            const std::string key = StringArg(*map, "key");
            if (key.empty()) continue;

            // ⌥ → Alt, ⌃/⌘ → Ctrl, ⇧ → Shift, win → tecla Windows.
            // NOREPEAT evita disparos contínuos ao segurar a tecla.
            UINT mods = MOD_NOREPEAT;
            if (BoolArg(*map, "alt")) mods |= MOD_ALT;
            if (BoolArg(*map, "ctrl") || BoolArg(*map, "cmd")) {
              mods |= MOD_CONTROL;
            }
            if (BoolArg(*map, "shift")) mods |= MOD_SHIFT;
            if (BoolArg(*map, "win")) mods |= MOD_WIN;

            // Teclas nomeadas (setas) ou dígitos '0'..'9' → VK 0x30..0x39.
            UINT vk;
            if (key == "left") {
              vk = VK_LEFT;
            } else if (key == "right") {
              vk = VK_RIGHT;
            } else {
              vk = static_cast<UINT>(key[0]);
            }

            if (RegisterHotKey(hwnd_, id, mods, vk)) {
              registered_ids_.push_back(id);
            }
          }
        }
      }
    }
    result->Success(EncodableValue(true));
  } else if (method == "unregisterAll") {
    UnregisterAll();
    result->Success();
  } else {
    result->NotImplemented();
  }
}

std::unique_ptr<flutter::StreamHandler<EncodableValue>>
ShortcutManager::CreateStreamHandler() {
  auto handler = std::make_unique<ForwardingStreamHandler>();
  handler->on_listen =
      [this](std::unique_ptr<flutter::EventSink<EncodableValue>>&& events) {
        sink_ = std::move(events);
      };
  handler->on_cancel = [this]() { sink_.reset(); };
  return handler;
}

void ShortcutManager::OnHotKey(int id) {
  if (sink_) {
    sink_->Success(EncodableValue(static_cast<int64_t>(id)));
  }
}
