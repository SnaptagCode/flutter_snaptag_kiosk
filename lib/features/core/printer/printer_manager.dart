import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:ffi' as ffi; // ffi 임포트 확인
import 'dart:isolate';
import 'dart:typed_data';
import 'package:ffi/ffi.dart'; // Utf8 사용을 위한 임포트
import 'package:flutter_snaptag_kiosk/features/core/printer/print_path.dart';
import 'package:flutter_snaptag_kiosk/features/core/printer/printer_log.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:image/image.dart' as img;

class PrinterManager {
  static PrinterManager? _instance;
  late SendPort _sendPort;

  PrinterManager._();

  static Future<PrinterManager> getInstance() async {
    if (_instance != null) return _instance!;
    _instance = PrinterManager._();
    await _instance!._init();
    return _instance!;
  }

  Future<void> _init() async {
    await _initPrintIsolate();
  }

  Future<void> _initPrintIsolate() async {
    try {
      final printReceivePort = ReceivePort();

      await Isolate.spawn(_printEntry, printReceivePort.sendPort);

      _sendPort = await printReceivePort.first;
    } catch (e) {
      logger.i(e);
    }
  }

  void _printEntry(SendPort sendPort) async {
    try {
      final isolateReceivePort = ReceivePort();
      sendPort.send(isolateReceivePort.sendPort);

      final PrinterBindings bindings = PrinterBindings();

      _initializePrinter(bindings);

      _printStatusCheck(bindings);

      isolateReceivePort.listen((message) async {
        if (message is Map<String, dynamic>) {
          final printPath = message['data'] as PrintPath;
          final replyPort = message['port'] as SendPort;

          logger.i('printPath: front ${printPath.frontPath} back ${printPath.backPath} replyPort: $replyPort');

          try {
            String? frontImageInfo;
            String? behindImageInfo;

            if (printPath.frontPath != null) {
              frontImageInfo = await drawImage(path: printPath.frontPath!, bindings: bindings);
            }

            if (printPath.backPath != null) {
              behindImageInfo = await drawImage(path: printPath.backPath!, bindings: bindings);
              // ❗️ 프로세스 충돌 발생, 파일을 삭제해야 됨.
              await File(printPath.backPath!).delete().catchError((_) {
                logger.i('Failed to delete rotated rear image');
              });
            }

            logger.i('5. Injecting card...');
            bindings.injectCard();

            logger.i('6. Printing card...');
            bindings.printCard(
              frontImageInfo: frontImageInfo,
              backImageInfo: behindImageInfo,
            );

            final printerLog = getPrinterLogData(bindings);

            logger.i('7. Ejecting card...');
            bindings.ejectCard();

            replyPort.send({'printStatus': printerLog});
          } catch (e) {
            logger.i('isolateReceivePort: $e');
            replyPort.send({'status': 'error'});
          }
        }
      });
    } catch (e) {
      logger.i(e);
    }
  }

  Future<PrinterLog?> startPrint({
    required File? frontFile,
    required File? embeddedFile,
  }) async {
    String? frontPath = frontFile?.path;
    String? rotatedRearPath;

    try {
      if (frontFile == null && embeddedFile == null) {
        throw Exception('There is nothing to print');
      }

      if (embeddedFile != null) {
        rotatedRearPath = await _rearImage(file: embeddedFile);
      }

      final responsePort = ReceivePort();

      _sendPort.send({'data': PrintPath(frontPath: frontPath, backPath: null), 'port': responsePort.sendPort});

      try {
        final response = await responsePort.first as Map<String, dynamic>;
        return response['printStatus'] as PrinterLog;
      } catch (e) {
        logger.i('error: $e');
      }

      return null;
    } catch (e, stack) {
      logger.i('error: $e stack: $stack');
      rethrow;
    }
  }

  Future<void> _initializePrinter(PrinterBindings bindings) async {
    try {
      bindings.initLibrary();

      // 2. 프린터 연결
      final connected = bindings.connectPrinter();
      if (!connected) {
        throw Exception('Failed to connect printer');
      }
      logger.i('Printer connected successfully');

      // 3. 리본 설정
      // 레거시 코드와 동일하게 setRibbonOpt 호출
      bindings.setRibbonOpt(1, 0, "2", 2);
      bindings.setRibbonOpt(1, 1, "255", 4);

      // 4. 프린터 준비 상태 확인
      final ready = bindings.ensurePrinterReady();
      if (!ready) {
        throw Exception('Failed to ensure printer ready');
      }

      logger.i('Printer initialization completed');
    } catch (e) {
      logger.i('Printer initialization error: $e');
      rethrow;
    }
  }

  void _printStatusCheck(PrinterBindings bindings) {
    try {
      // 피더 상태 체크 추가
      logger.i('Checking feeder status...');
      final hasCard = bindings.checkFeederStatus();
      if (!hasCard) {
        throw Exception('Card feeder is empty');
      }

      logger.i('1. Checking card position...');
      final hasCardInPrinter = bindings.checkCardPosition();
      if (hasCardInPrinter) {
        logger.i('Card found, ejecting...');
        bindings.ejectCard();
      }
    } catch (e, stack) {
      logger.i('Print error: $e\nStack: $stack');
      rethrow;
    }
  }

  PrinterLog getPrinterLogData(PrinterBindings bindings) {
    try {
      final printerStatus = bindings.getPrinterStatus(0);
      final ribbonStatus = bindings.getRbnAndFilmRemaining();
      final isPrintingNow = bindings.checkCardPosition();
      final isFeederEmpty = !bindings.checkFeederStatus();
      // final errorMsg = printerStatus.$2 == null ? '' : bindings.getErrorInfo(printerStatus.$2 ?? 0);
      logger.i(
          'Printer status: $printerStatus, ribbon status: $ribbonStatus, isPrintingNow: $isPrintingNow isFeederEmpty: $isFeederEmpty');

      return PrinterLog(
          sdkMainCode: (printerStatus?.mainCode ?? 0).toString(),
          sdkSubCode: (printerStatus?.mainCode ?? 0).toString(),
          printerMainStatusCode: (printerStatus?.mainStatus ?? 0).toString(),
          printerErrorStatusCode: (printerStatus?.errorStatus ?? 0).toString(),
          printerWarningStatusCode: (printerStatus?.warningStatus ?? 0).toString(),
          chassisTemperature: printerStatus?.chassisTemperature ?? 0,
          printerHeadTemperature: printerStatus?.printHeadTemperature ?? 0,
          heaterTemperature: printerStatus?.heaterTemperature ?? 0,
          rbnRemainingRatio: ribbonStatus?.rbnRemaining ?? 0,
          filmRemainingRatio: ribbonStatus?.filmRemaining ?? 0,
          isPrintingNow: isPrintingNow,
          isFeederEmpty: isFeederEmpty,
          sdkErrorMessage: '');
    } catch (e) {
      rethrow;
    }
  }

  void printStatus(PrinterBindings bindings) {
    final status = bindings.getPrinterStatus(0);
    if (status != null) {
      logger.i(
          'status mainCode ${status.mainCode} mainStatus ${status.mainStatus} errorStatus ${status.errorStatus} subCode ${status.subCode} wariningStatus ${status.warningStatus}');
    } else {
      logger.i('status null');
    }
  }

  Future<String> _rearImage({required File file}) async {
    final rearImage = await file.readAsBytes();
    final rotatedRearImage = _flipImage180(rearImage);
    // 임시 파일로 저장
    final temp = DateTime.now().millisecondsSinceEpoch.toString();
    final rotatedRearPath = '${temp}_rotated.png';
    await File(rotatedRearPath).writeAsBytes(rotatedRearImage);

    return rotatedRearPath;
  }

  // 이미지 회전 기능 추가
  Uint8List _flipImage180(Uint8List imageBytes) {
    final originalImage = img.decodeImage(imageBytes);
    if (originalImage != null) {
      final flippedImage = img.copyRotate(originalImage, angle: 180);
      return Uint8List.fromList(img.encodePng(flippedImage));
    }
    return imageBytes;
  }

  Future<String> drawImage({required String path, required PrinterBindings bindings}) async {
    StringBuffer buffer = StringBuffer();
    try {
      await _prepareAndDrawImageTest(path, true, bindings);

      logger.i('Committing canvas...');
      buffer.write(_commitCanvas(bindings));

      return buffer.toString();
    } catch (e, stack) {
      logger.i('Error in front canvas preparation: $e\nStack: $stack');
      throw Exception('Failed to prepare front canvas: $e');
    }
  }

  Future<void> _prepareAndDrawImageTest(String imagePath, bool isFront, PrinterBindings bindings) async {
    bindings.setCanvasOrientation(true);
    bindings.prepareCanvas(isColor: true);

    logger.i('Drawing image...');
    bindings.drawImage(
      imagePath: imagePath,
      x: -1,
      y: -1,
      width: 56.0,
      height: 88.0,
      noAbsoluteBlack: true,
    );
    logger.i('Drawing empty text...');
    // 제거 시 이미지 출력이 안됨
    bindings.drawText(
      text: '',
      x: 0,
      y: 0,
      width: 0,
      height: 0,
      noAbsoluteBlack: true,
    );
  }

  String _commitCanvas(PrinterBindings bindings) {
    final strPtr = calloc<ffi.Uint8>(200).cast<Utf8>();
    final lenPtr = calloc<ffi.Int32>()..value = 200;

    try {
      final result = bindings.commitCanvas(strPtr, lenPtr);
      if (result != 0) {
        throw Exception('Failed to commit canvas');
      }
      return strPtr.toDartString();
    } finally {
      calloc.free(strPtr);
      calloc.free(lenPtr);
    }
  }
}
