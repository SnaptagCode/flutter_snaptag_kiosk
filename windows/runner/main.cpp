#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <windows.h>

#include <ctime>
#include <exception>
#include <fstream>
#include <string>

#include "flutter_window.h"
#include "utils.h"

static std::wstring GetCrashLogPath() {
  wchar_t path[MAX_PATH];
  GetModuleFileNameW(nullptr, path, MAX_PATH);
  std::wstring exePath(path);
  size_t pos = exePath.find_last_of(L"\\/");
  return exePath.substr(0, pos + 1) + L"crash_log.txt";
}

static void WriteCrashLog(const std::string& reason) {
  std::wstring logPath = GetCrashLogPath();
  std::ofstream file(logPath);
  if (file.is_open()) {
    time_t now = time(nullptr);
    file << "[CRASH] " << reason << "\n";
    file << "Time: " << ctime(&now);
    file.close();
  }
}

// 4. SetUnhandledExceptionFilter — OS 레벨 크래시 감지
LONG WINAPI UnhandledExceptionHandler(EXCEPTION_POINTERS* info) {
  char msg[128];
  snprintf(msg, sizeof(msg), "SetUnhandledExceptionFilter: ExceptionCode=0x%lx",
           info->ExceptionRecord->ExceptionCode);
  WriteCrashLog(msg);
  return EXCEPTION_EXECUTE_HANDLER;
}

// 5. std::set_terminate — 처리되지 않은 C++ 예외 감지
void TerminateHandler() {
  WriteCrashLog("std::terminate called (uncaught C++ exception)");
  abort();
}

int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ wchar_t *command_line, _In_ int show_command) {
  SetUnhandledExceptionFilter(UnhandledExceptionHandler);
  std::set_terminate(TerminateHandler);

  // Attach to console when present (e.g., 'flutter run') or create a
  // new console when running with a debugger.
  if (!::AttachConsole(ATTACH_PARENT_PROCESS) && ::IsDebuggerPresent()) {
    CreateAndAttachConsole();
  }

  // Initialize COM, so that it is available for use in the library and/or
  // plugins.
  ::CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);

  flutter::DartProject project(L"data");

  std::vector<std::string> command_line_arguments =
      GetCommandLineArguments();

  project.set_dart_entrypoint_arguments(std::move(command_line_arguments));

  FlutterWindow window(project);
  Win32Window::Point origin(10, 10);
  Win32Window::Size size(1280, 720);
  if (!window.Create(L"flutter_snaptag_kiosk", origin, size)) {
    return EXIT_FAILURE;
  }
  window.SetQuitOnClose(true);

  ::MSG msg;
  while (::GetMessage(&msg, nullptr, 0, 0)) {
    ::TranslateMessage(&msg);
    ::DispatchMessage(&msg);
  }

  ::CoUninitialize();
  return EXIT_SUCCESS;
}
