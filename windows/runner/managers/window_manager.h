#ifndef RUNNER_MANAGERS_WINDOW_MANAGER_H_
#define RUNNER_MANAGERS_WINDOW_MANAGER_H_

#include <flutter/method_channel.h>
#include <flutter/standard_method_codec.h>
#include <windows.h>

#include <memory>
#include <vector>

// Lista as janelas de topo (EnumWindows) e as manipula via Win32
// (SetWindowPos/ShowWindow/SetForegroundWindow). Espelha o WindowManager
// do macOS, com o HWND fazendo o papel do CGWindowID.
//
// Posições e tamanhos entram e saem daqui como frame VISUAL (sem as bordas
// invisíveis do DWM) — a conversão fica em window_geometry.
//
// Limitação: sem elevação, o FlowDesk não consegue reposicionar janelas de
// processos elevados (UIPI); nesses casos setWindowFrame devolve false.
//
// Thread-safety: os handlers de MethodChannel rodam na platform thread, que
// é a dona do HWND do runner e roda o message loop — a mesma exigida por
// SetTimer/KillTimer. Por isso `pending_` não precisa de lock.
class WindowManager {
 public:
  // Timer das reaplicações de `settle` (roteado pelo ChannelRouter).
  static constexpr UINT_PTR kSettleTimerId = 0xF10D;

  WindowManager();
  ~WindowManager();

  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue>& call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

  // |hwnd| é a janela do runner, dona do timer de settle.
  void SetRunnerWindow(HWND hwnd) { runner_hwnd_ = hwnd; }

  // Chamado pelo runner a cada WM_TIMER de kSettleTimerId.
  void OnSettleTick();

 private:
  // Frame a reaplicar depois que o app terminar de se acomodar: alguns apps
  // restauram o próprio tamanho centenas de ms após o resize.
  struct PendingFrame {
    HWND hwnd = nullptr;
    RECT visual{};
    ULONGLONG deadlines[3]{};
    int next = 0;
  };

  flutter::EncodableValue WindowsPayload();
  bool SetWindowFrame(HWND hwnd, int x, int y, int width, int height,
                      bool settle);
  bool FocusWindow(HWND hwnd);

  void SchedulePending(HWND hwnd, const RECT& visual);
  void CancelPending(HWND hwnd);
  void EnsureTimer();

  std::vector<PendingFrame> pending_;
  HWND runner_hwnd_ = nullptr;
  bool timer_active_ = false;

  ULONG_PTR gdiplus_token_ = 0;
};

#endif  // RUNNER_MANAGERS_WINDOW_MANAGER_H_
