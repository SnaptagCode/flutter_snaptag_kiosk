// ffi 임포트 확인
import 'dart:async';
import 'dart:io';

// Utf8 사용을 위한 임포트
import 'package:flutter_snaptag_kiosk/features/core/printer/printer_manager.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'card_printer.g.dart';

@Riverpod(keepAlive: true)
class PrinterService extends _$PrinterService {
  final PrinterManager _printerManager = PrinterManager();
  Timer? _timer;
  bool isPrinting = false;
  bool isLogging = false;

  @override
  FutureOr<void> build() async {
    // _printerIso.initializePrinter();
  }

  Future<void> startPrinterLogging() async {
    _timer ??= Timer.periodic(Duration(seconds: 10), (timer) async {
      try {
        await printLogo();
      } catch (e) {
        logger.i(e);
      }
    });
  }

  void stopLogTimer() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> printLogo() async {
    try {
      final machineId = ref.read(kioskInfoServiceProvider)?.kioskMachineId ?? 0;
      final printerLogo = await _printerManager.getPrinterLogData(machineId);
      SlackLogService().sendLogToSlack('printerState: $printerLogo');
      if (machineId != 0) {
        await ref.read(kioskRepositoryProvider).updatePrintLog(request: printerLogo);
      }
    } catch (e) {
      SlackLogService().sendLogToSlack('printerError: $e');
      rethrow;
    } finally {
      // isLogging = false;
    }
  }

  Future<void> printImage({
    required File? frontFile,
    required File? backFile,
  }) async {
    try {
      state = const AsyncValue.loading();

      await _printerManager.printImage(frontFile: frontFile, embeddedFile: backFile);
    } catch (e) {
      SlackLogService().sendLogToSlack('printerError: $e');
      // TODO : 프린트 중 발생한 에러를 여기서 확인. -> 로깅
      rethrow;
    } finally {
      // isPrinting = false;
    }
  }
}
