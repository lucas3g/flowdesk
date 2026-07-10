#include "app_identity.h"

#include <propkey.h>
#include <shlobj.h>

#include "string_utils.h"

std::wstring ProcessImagePath(DWORD pid) {
  HANDLE process = OpenProcess(PROCESS_QUERY_LIMITED_INFORMATION, FALSE, pid);
  if (!process) {
    return L"";
  }
  wchar_t buffer[MAX_PATH] = {};
  DWORD size = MAX_PATH;
  std::wstring path;
  if (QueryFullProcessImageNameW(process, 0, buffer, &size)) {
    path.assign(buffer, size);
  }
  CloseHandle(process);
  return path;
}

std::string BaseName(const std::wstring& path) {
  size_t slash = path.find_last_of(L"\\/");
  std::wstring name =
      slash == std::wstring::npos ? path : path.substr(slash + 1);
  return Utf8FromUtf16(name);
}

std::string WindowAumid(HWND hwnd) {
  IPropertyStore* store = nullptr;
  if (FAILED(SHGetPropertyStoreForWindow(hwnd, IID_PPV_ARGS(&store)))) {
    return "";
  }
  std::string result;
  PROPVARIANT prop;
  PropVariantInit(&prop);
  if (SUCCEEDED(store->GetValue(PKEY_AppUserModel_ID, &prop)) &&
      prop.vt == VT_LPWSTR && prop.pwszVal != nullptr) {
    result = Utf8FromUtf16(prop.pwszVal);
  }
  PropVariantClear(&prop);
  store->Release();
  return result;
}

std::string WindowAppId(HWND hwnd, DWORD pid) {
  std::string aumid = WindowAumid(hwnd);
  if (!aumid.empty()) {
    return aumid;
  }
  return BaseName(ProcessImagePath(pid));
}
