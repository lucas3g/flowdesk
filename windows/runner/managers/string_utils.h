#ifndef RUNNER_MANAGERS_STRING_UTILS_H_
#define RUNNER_MANAGERS_STRING_UTILS_H_

#include <windows.h>

#include <string>

// Converte uma string UTF-16 (Windows) para UTF-8 (usado pelos canais Flutter).
inline std::string Utf8FromUtf16(const std::wstring& utf16) {
  if (utf16.empty()) {
    return std::string();
  }
  int size = WideCharToMultiByte(CP_UTF8, 0, utf16.data(),
                                 static_cast<int>(utf16.size()), nullptr, 0,
                                 nullptr, nullptr);
  std::string utf8(size, 0);
  WideCharToMultiByte(CP_UTF8, 0, utf16.data(),
                      static_cast<int>(utf16.size()), utf8.data(), size,
                      nullptr, nullptr);
  return utf8;
}

#endif  // RUNNER_MANAGERS_STRING_UTILS_H_
