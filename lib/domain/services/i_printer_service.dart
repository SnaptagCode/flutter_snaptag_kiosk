import 'dart:io';

abstract interface class IPrinterService {
  Future<void> printImage({
    required File? frontFile,
    required File? embeddedFile,
    required bool isSingleMode,
  });
}
