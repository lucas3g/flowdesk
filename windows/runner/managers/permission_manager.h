#ifndef RUNNER_MANAGERS_PERMISSION_MANAGER_H_
#define RUNNER_MANAGERS_PERMISSION_MANAGER_H_

#include <flutter/method_channel.h>
#include <flutter/standard_method_codec.h>

#include <memory>

// Permissões do sistema. No Windows a manipulação de janelas não exige
// concessão explícita (diferente da Accessibility do macOS), então o
// status é sempre "concedido".
class PermissionManager {
 public:
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue>& call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

#endif  // RUNNER_MANAGERS_PERMISSION_MANAGER_H_
