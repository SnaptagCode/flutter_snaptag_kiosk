import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:ffi' as ffi; // ffi 임포트 확인
import 'package:ffi/ffi.dart'; // Utf8 사용을 위한 임포트
import 'package:flutter_snaptag_kiosk/core/isolate/isolate_manager.dart';
import 'package:flutter_snaptag_kiosk/features/core/printer/print_path.dart';
import 'package:flutter_snaptag_kiosk/features/core/printer/printer_log.dart';
import 'package:flutter_snaptag_kiosk/features/core/printer/ribbon_status.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';

class PrinterManager {
  late PrinterBindings _bindings;
  Timer? _timer;

  Future<void> initializePrinter() async {
    try {
      // 1. 라이브러리 초기화 전에 이전 상태 정리
      _bindings.clearLibrary();

      // 2. 프린터 연결
      final connected = _bindings.connectPrinter();
      if (!connected) {
        throw Exception('Failed to connect printer');
      }
      logger.i('Printer connected successfully');

      // 3. 리본 설정
      // 레거시 코드와 동일하게 setRibbonOpt 호출
      _bindings.setRibbonOpt(1, 0, "2", 2);
      _bindings.setRibbonOpt(1, 1, "255", 4);

      // 4. 프린터 준비 상태 확인
      final ready = _bindings.ensurePrinterReady();
      if (!ready) {
        throw Exception('Failed to ensure printer ready');
      }

      logger.i('Printer initialization completed');
    } catch (e) {
      logger.i('Printer initialization error: $e');
      rethrow;
    }
  }

  Future<void> printImage({
    required File? frontFile,
    required File? embeddedFile,
  }) async {
    try {
      if (frontFile == null && embeddedFile == null) {
        throw Exception('There is nothing to print');
      }

      String? frontPath = frontFile?.path;
      String? rotatedRearPath;

      if (embeddedFile != null) {
        rotatedRearPath = await rearImage(file: embeddedFile);
      }

      IsolateManager<PrintPath, void>()
          .runInIsolate(_printImageIsolate, PrintPath(frontPath: frontPath, backPath: rotatedRearPath));
    } catch (e, stack) {
      logger.i('Print error: $e\nStack: $stack');
      rethrow;
    }
  }

  Future<void> _printImageIsolate(PrintPath printPath) async {
    try {
      // 꼭 이 함수 안에서 객체를 초기화 해줘야 함.
      _bindings = PrinterBindings();

      initializePrinter();

      printInit();

      String? frontImageInfo;
      String? behindImageInfo;

      if (printPath.frontPath != null) {
        frontImageInfo = await drawImage(path: printPath.frontPath!);
      }

      if (printPath.backPath != null) {
        behindImageInfo = await drawImage(path: printPath.backPath!);
      }

      logger.i('5. Injecting card...');
      _bindings.injectCard();

      logger.i('6. Printing card...');
      _bindings.printCard(
        frontImageInfo: frontImageInfo,
        backImageInfo: behindImageInfo,
      );

      logger.i('7. Ejecting card...');
      _bindings.ejectCard();
    } catch (error, stack) {
      logger.i('_printImageIsolation error: $error\nStack: $stack');
    }
  }

  void printInit() {
    try {
      // 피더 상태 체크 추가
      logger.i('Checking feeder status...');
      final hasCard = _bindings.checkFeederStatus();
      if (!hasCard) {
        throw Exception('Card feeder is empty');
      }

      logger.i('1. Checking card position...');
      final hasCardInPrinter = _bindings.checkCardPosition();
      if (hasCardInPrinter) {
        logger.i('Card found, ejecting...');
        _bindings.ejectCard();
      }
    } catch (e, stack) {
      logger.i('Print error: $e\nStack: $stack');
      rethrow;
    }
  }

  Future<String> drawImage({required String path}) async {
    StringBuffer buffer = StringBuffer();
    try {
      await _prepareAndDrawImage(path, true);

      logger.i('Committing canvas...');
      buffer.write(_commitCanvas());

      return buffer.toString();
    } catch (e, stack) {
      logger.i('Error in front canvas preparation: $e\nStack: $stack');
      throw Exception('Failed to prepare front canvas: $e');
    }
  }

  Future<String> rearImage({required File file}) async {
    final rearImage = await file.readAsBytes();
    final rotatedRearImage = _bindings.flipImage180(rearImage);
    // 임시 파일로 저장
    final temp = DateTime.now().millisecondsSinceEpoch.toString();
    final rotatedRearPath = '${temp}_rotated.png';
    await File(rotatedRearPath).writeAsBytes(rotatedRearImage);

    return rotatedRearPath;
  }

  Future<void> _prepareAndDrawImage(String imagePath, bool isFront) async {
    _bindings.setCanvasOrientation(true);
    _bindings.prepareCanvas(isColor: true);

    logger.i('Drawing image...');
    _bindings.drawImage(
      imagePath: imagePath,
      x: -1,
      y: -1,
      width: 56.0,
      height: 88.0,
      noAbsoluteBlack: true,
    );
    logger.i('Drawing empty text...');
    // 제거 시 이미지 출력이 안됨
    _bindings.drawText(
      text: '',
      x: 0,
      y: 0,
      width: 0,
      height: 0,
      noAbsoluteBlack: true,
    );
  }

  // 프린터 상태 모니터링 메서드 추가
  String _commitCanvas() {
    final strPtr = calloc<ffi.Uint8>(200).cast<Utf8>();
    final lenPtr = calloc<ffi.Int32>()..value = 200;
    String commitResult = "";

    try {
      final result = _bindings.commitCanvas(strPtr, lenPtr);
      if (result != 0) {
        throw Exception('Failed to commit canvas');
      }
      commitResult = strPtr.toDartString();
    } finally {
      calloc.free(strPtr);
      calloc.free(lenPtr);
    }
    return commitResult;
  }

  Future<PrinterLog> backgroundPrinterLogTask(int machineId) async {
    final result = await IsolateManager<int, PrinterLog>().runInIsolate(getPrinterLogData, machineId);
    return result ?? PrinterLog();
  }

  PrinterLog getPrinterLogData(int machineId) {
    final bindings = PrinterBindings();

    // 1. 초기화
    bindings.clearLibrary();

    // 2. 프린터 연결
    bindings.connectPrinter();

    try {
      final printerStatus = bindings.getPrinterStatus(machineId);
      final ribbonStatus = bindings.getRbnAndFilmRemaining();
      final isPrintingNow = bindings.checkCardPosition();
      final isFeederEmpty = !bindings.checkFeederStatus();
      // final errorMsg = _bindings.getErrorInfo(printerStatus?.errorStatus ?? 0);
      logger.i(
          'Printer status: $printerStatus, machineId: $machineId ribbon status: $ribbonStatus, isPrintingNow: $isPrintingNow, isFeederEmpty: $isFeederEmpty');

      return PrinterLog(
          printerStatus: printerStatus,
          ribbonStatus: ribbonStatus,
          isPrintingNow: isPrintingNow,
          isFeederEmpty: isFeederEmpty,
          errorMsg: '');
    } catch (e) {
      logger.i('getPrinterLogData error: $e');
    }
    return PrinterLog();
  }

  PrinterStatus? getPrinterStatus(int machineId) {
    try {
      final status = _bindings.getPrinterStatus(machineId);

      if (status != null) {
        logger.i(
            'Printer mainCode: ${status.mainCode}, subCode: ${status.subCode}, mainStatus: ${status.mainStatus}, errorStatus: ${status.errorStatus}, warningStatus: ${status.warningStatus}, chassisTemperature: ${status.chassisTemperature}, printHeadTemperature: ${status.printHeadTemperature}, heaterTemperature: ${status.heaterTemperature}, subStatus: ${status.subStatus}');
      }
      return status;
    } catch (e) {
      logger.i('getPrinterStatus error: $e');
    }
    return null;
  }

  RibbonStatus? getRbnAndFilmRemaining() {
    try {
      final status = _bindings.getRbnAndFilmRemaining();
      logger.i("Printer ribbonRemaining: ${status?.rbnRemaining}, filmRemaining: ${status?.filmRemaining}");
      return status;
    } catch (e) {
      logger.i('getRbnAndFilmRemaining error: $e');
    }
    return null;
  }

  bool checkCardPosition() {
    try {
      final status = _bindings.checkCardPosition();
      logger.i('Printer checkCardPosition: 카드 ${status == true ? "있음" : "없음"}');
      return status;
    } catch (e) {
      logger.i('checkCardPosition error: $e');
    }
    return false;
  }

  bool checkFeederStatus() {
    try {
      final status = _bindings.checkFeederStatus();
      logger.i('Printer checkFeederStatus: 카드 공급기 ${status == true ? "있음" : "없음"}');
      return status;
    } catch (e) {
      logger.i('checkFeederStatus error: $e');
    }
    return false;
  }

  void getConnectPrintList() {
    try {
      final result = _bindings.enumUsbPrinter();
      logger.i('Printer getConnectPrintList: ${result.join(', ')}');
    } catch (e) {
      logger.i('getConnectPrintList error: $e');
    }
  }

  void ejectCard() {
    try {
      _bindings.ejectCard();
      logger.i('Printer ejectCard');
    } catch (e) {
      logger.i('Printer ejectCard error: $e');
    }
  }
}
