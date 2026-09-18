#ifndef RUNNER_MANAGERS_SNAP_MANAGER_H_
#define RUNNER_MANAGERS_SNAP_MANAGER_H_

#include <flutter/method_channel.h>
#include <flutter/standard_method_codec.h>
#include <windows.h>

#include <cstdint>
#include <memory>
#include <string>
#include <utility>
#include <vector>

// Encaixe por regiões do layout: com o recurso ativo, arrastar uma janela
// de outro app mostra as zonas do último layout aplicado (overlay) e, ao
// soltar dentro de uma zona, a janela é redimensionada para ela.
//
// O arrasto é detectado por SetWinEventHook com EVENT_SYSTEM_MOVESIZESTART/
// MOVESIZEEND. Isso é essencial: arrastar uma janela coloca o Windows num
// laço modal de move/size que grava a posição final ao soltar o botão. Um
// hook de mouse (WH_MOUSE_LL) recebe o WM_LBUTTONUP *antes* desse laço
// terminar, então o encaixe aplicado ali era sobrescrito logo em seguida —
// era esse o motivo de o recurso não funcionar. O MOVESIZEEND chega depois
// do laço, quando nada mais reposiciona a janela.
//
// Limitações conhecidas:
// - Apps com barra de título própria que implementam o arrasto na mão não
//   emitem MOVESIZESTART/END (Chromium, Electron e Qt usam o laço nativo e
//   emitem). Se algum app precisar de suporte, a saída é um detector
//   secundário por EVENT_OBJECT_LOCATIONCHANGE com aplicação adiada — e não
//   voltar ao WH_MOUSE_LL.
// - Sem elevação, janelas de processos elevados (UIPI) não geram eventos
//   nem aceitam reposicionamento.
// - O overlay é uma janela única cobrindo a área de trabalho virtual; em
//   multi-monitor com DPIs diferentes isso é aproximado (um overlay por
//   monitor seria o ideal).
class SnapManager {
 public:
  // Timer que acompanha o cursor enquanto o arrasto está em andamento.
  static constexpr UINT_PTR kTrackTimerId = 0xF10E;

  ~SnapManager();

  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue>& call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

  // |hwnd| é a janela do runner, dona do timer de tracking.
  void SetWindow(HWND hwnd) { runner_hwnd_ = hwnd; }

  // Chamado pelo runner a cada WM_TIMER de kTrackTimerId.
  void OnTrackTick();

 private:
  void Enable();
  void Disable();

  static void CALLBACK WinEventProc(HWINEVENTHOOK hook, DWORD event,
                                    HWND hwnd, LONG id_object, LONG id_child,
                                    DWORD thread, DWORD time);
  static LRESULT CALLBACK OverlayWndProc(HWND hwnd, UINT message,
                                         WPARAM wparam, LPARAM lparam);

  void OnMoveSizeStart(HWND hwnd);
  void OnMoveSizeEnd(HWND hwnd);
  void ResetDragState();

  // Índice da zona sob o ponto, ou -1.
  int ZoneAt(POINT pt) const;

  void ShowZones();
  void HideZones();
  void PaintZones(HDC hdc);

  // Instância única para os callbacks estáticos (o runner cria um só
  // SnapManager).
  static SnapManager* instance_;

  HWINEVENTHOOK move_hook_ = nullptr;
  bool enabled_ = false;
  HWND runner_hwnd_ = nullptr;
  bool timer_active_ = false;
  // Zonas em coordenadas absolutas da área de trabalho virtual (pixels).
  std::vector<RECT> regions_;
  // Apps (AUMID ou nome do exe) — ou instâncias, por HWND — que não
  // participam do encaixe ao arrastar. windowId 0 = app inteiro.
  std::vector<std::pair<std::string, int64_t>> excluded_;

  bool IsExcluded(HWND hwnd, DWORD pid) const;

  // Estado do arrasto em andamento.
  HWND dragged_ = nullptr;
  RECT drag_start_rect_{};
  bool window_moving_ = false;
  int suggested_index_ = -1;

  // Overlay único cobrindo a área de trabalho virtual.
  HWND overlay_ = nullptr;
  bool overlay_class_registered_ = false;
};

#endif  // RUNNER_MANAGERS_SNAP_MANAGER_H_
