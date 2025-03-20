// ffi 임포트 확인
import 'dart:async';
import 'dart:io';

// Utf8 사용을 위한 임포트
import 'package:flutter_snaptag_kiosk/data/datasources/cache/cache.dart';
import 'package:flutter_snaptag_kiosk/features/core/printer/printer_manager.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'card_printer.g.dart';

@Riverpod(keepAlive: true)
class PrinterService extends _$PrinterService {
  final PrinterManager _printerIso = PrinterManager();
  Timer? _timer;

  @override
  FutureOr<void> build() async {
    // _printerIso.initializePrinter();
  }

  Future<void> startPrinterLogging() async {
    final machineId = ref.read(kioskInfoServiceProvider)?.kioskMachineId ?? 0;
    _timer = Timer.periodic(Duration(seconds: 10), (timer) async {
      final printerLogo = await _printerIso.backgroundPrinterLogTask(machineId);
    });
  }

  void stopLogTimer() {
    _timer?.cancel();
    _timer = null;
  }

  // Future<void> printImage({
  //   required File? frontFile,
  //   required String? backPhotoImageUrl,
  // }) async {
  //   try {
  //     state = const AsyncValue.loading();

  //     _printerIso.printImageNew(frontFile: frontFile, backPhotoImageUrl: backPhotoImageUrl);
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  Future<void> printImage({
    required File? frontFile,
    required File? backFile,
  }) async {
    try {
      state = const AsyncValue.loading();

      _printerIso.printImage(frontFile: frontFile, embeddedFile: backFile);
    } catch (e) {
      rethrow;
    }
  }
}
