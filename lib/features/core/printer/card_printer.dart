// ffi 임포트 확인
import 'dart:io';

// Utf8 사용을 위한 임포트
import 'package:flutter_snaptag_kiosk/core/utils/logger_service.dart';
import 'package:flutter_snaptag_kiosk/features/core/printer/printer_iso.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'card_printer.g.dart';

@Riverpod(keepAlive: true)
class PrinterService extends _$PrinterService {
  final PrinterIso _printerIso = PrinterIso();

  @override
  FutureOr<void> build() async {
    _printerIso.initializePrinter();
  }

  Future<void> printImage({
    required File? frontFile,
    required File? embeddedFile,
  }) async {
    try {
      state = const AsyncValue.loading();
      _printerIso.printImage(frontFile: frontFile, embeddedFile: embeddedFile);
    } catch (e, stack) {
      logger.i('Print error: $e\nStack: $stack');
      rethrow;
    }
  }
}
