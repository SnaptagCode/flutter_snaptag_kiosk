import 'dart:io';

// Utf8 사용을 위한 임포트
import 'package:flutter_snaptag_kiosk/features/core/printer/printer_manager.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'card_printer.g.dart';

@Riverpod(keepAlive: true)
class PrinterService extends _$PrinterService {
  @override
  FutureOr<void> build() async {}

  Future<void> printImage({
    required File? frontFile,
    required File? backFile,
  }) async {
    try {
      state = const AsyncValue.loading();

      final printerManager = await PrinterManager.getInstance();

      await printerManager.startPrint(frontFile: frontFile, embeddedFile: backFile);

      // await _printerManager.printImageTest(frontFile: frontFile, embeddedFile: backFile);
    } catch (e) {
      rethrow;
    } finally {
      // isPrinting = false;
    }
  }
}
