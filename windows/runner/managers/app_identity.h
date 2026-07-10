#ifndef RUNNER_MANAGERS_APP_IDENTITY_H_
#define RUNNER_MANAGERS_APP_IDENTITY_H_

#include <windows.h>

#include <string>

// Identificação do app dono de uma janela/processo — compartilhada entre os
// managers para que todos enxerguem o mesmo id que o lado Dart usa como
// `bundleId` (AUMID quando disponível; senão o nome do executável).

// Caminho completo do executável do processo (vazio em caso de falha).
std::wstring ProcessImagePath(DWORD pid);

// Nome do arquivo (UTF-8) a partir de um caminho.
std::string BaseName(const std::wstring& path);

// AUMID da janela; vazio quando o app não expõe um.
std::string WindowAumid(HWND hwnd);

// Id estável do app da janela: AUMID ou, na ausência, o nome do executável.
std::string WindowAppId(HWND hwnd, DWORD pid);

#endif  // RUNNER_MANAGERS_APP_IDENTITY_H_
