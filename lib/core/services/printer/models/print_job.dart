import 'dart:io';

/// 인쇄 1회에 필요한 입력. 단면/메탈 여부 등 정책 판단은 호출자(PrinterService)가 한다.
class PrintJob {
  const PrintJob({
    required this.frontFile,
    required this.backFile,
    required this.isSingleMode,
    required this.isMetal,
  });

  final File? frontFile;
  final File? backFile;
  final bool isSingleMode;
  final bool isMetal;
}
