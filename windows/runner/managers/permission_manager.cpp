#include "permission_manager.h"

#include <shellapi.h>

using flutter::EncodableMap;
using flutter::EncodableValue;

void PermissionManager::HandleMethodCall(
    const flutter::MethodCall<EncodableValue>& call,
    std::unique_ptr<flutter::MethodResult<EncodableValue>> result) {
  const std::string& method = call.method_name();

  if (method == "getStatus") {
    result->Success(EncodableValue(EncodableMap{
        {EncodableValue("accessibility"), EncodableValue(true)},
        {EncodableValue("screenRecording"), EncodableValue(true)},
    }));
  } else if (method == "requestAccessibility") {
    result->Success(EncodableValue(true));
  } else if (method == "requestScreenRecording") {
    result->Success(EncodableValue(true));
  } else if (method == "openSystemSettings") {
    // Abre as configurações de multitarefa/tela do Windows.
    ShellExecuteW(nullptr, L"open", L"ms-settings:multitasking", nullptr,
                  nullptr, SW_SHOWNORMAL);
    result->Success();
  } else {
    result->NotImplemented();
  }
}
