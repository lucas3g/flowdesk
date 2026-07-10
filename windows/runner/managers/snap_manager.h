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
// O rastreamento usa um hook global de mouse de baixo nível (WH_MOUSE_LL),
// que não exige DLL e roda na thread com message loop (a principal).
class SnapManager {
 public:
  ~SnapManager();

  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue>& call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

 private:
  void Enable();
  void Disable();

  static LRESULT CALLBACK MouseHookProc(int code, WPARAM wparam,
                                        LPARAM lparam);
  static LRESULT CALLBACK OverlayWndProc(HWND hwnd, UINT message,
                                         WPARAM wparam, LPARAM lparam);

  void OnMouseDown(POINT pt);
  void OnMouseMove(POINT pt);
  void OnMouseUp();
  void ResetDragState();

  void ShowZones();
  void HideZones();
  void PaintZones(HDC hdc);

  // Instância única para o hook estático (o runner cria um só SnapManager).
  static SnapManager* instance_;

  HHOOK hook_ = nullptr;
  bool enabled_ = false;
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
