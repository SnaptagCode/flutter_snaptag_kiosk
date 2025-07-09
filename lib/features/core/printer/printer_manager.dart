import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:ffi' as ffi; // ffi 임포트 확인
import 'dart:isolate';
import 'dart:typed_data';
import 'package:ffi/ffi.dart'; // Utf8 사용을 위한 임포트
import 'package:flutter_snaptag_kiosk/features/core/printer/connect_message.dart';
import 'package:flutter_snaptag_kiosk/features/core/printer/print_message.dart';
import 'package:flutter_snaptag_kiosk/features/core/printer/print_path.dart';
import 'package:flutter_snaptag_kiosk/features/core/printer/print_ribbon_status.dart';
import 'package:flutter_snaptag_kiosk/features/core/printer/print_state_message.dart';
import 'package:flutter_snaptag_kiosk/features/core/printer/printer_log.dart';
import 'package:flutter_snaptag_kiosk/features/core/printer/ribbon_status.dart';
import 'package:flutter_snaptag_kiosk/features/core/printer/setting_printer_message.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:image/image.dart' as img;

class PrinterManager {
  static PrinterManager? _instance;
  late SendPort _sendPort;

  PrinterManager._();

  static Future<PrinterManager> getInstance() async {
    try {
      if (_instance != null) return _instance!;
      logger.i('PrinterManager Initializing PrinterManager...');
      _instance = PrinterManager._();
      await _instance!._init();
      return _instance!;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _init() async {
    try {
      logger.i('PrinterManager Starting PrinterManager initialization...');
      await _initPrintIsolate();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _initPrintIsolate() async {
    try {
      logger.i('PrinterManager Initializing print isolate...');
      final printReceivePort = ReceivePort();

      await Isolate.spawn(_printEntry, printReceivePort.sendPort);

      _sendPort = await printReceivePort.first;
    } catch (e) {
      logger.i(e);
      rethrow;
    }
  }

  void _printEntry(SendPort sendPort) async {
    try {
      logger.i('PrinterManager Print isolate entry point started');
      final isolateReceivePort = ReceivePort();
      sendPort.send(isolateReceivePort.sendPort);

      final PrinterBindings bindings = PrinterBindings();

      // 프린트 초기화 작업
      _initializePrinter(bindings);

      isolateReceivePort.listen((message) async {
        SendPort? replyPort;
        try {
          if (message is ConnectMessage) {
            replyPort = message.sendPort;
            final isConnected = await _checkConnectedPrint(bindings);
            logger.i('_printEntry ConnectMessage: $isConnected');
            replyPort.send({'isConnected': isConnected});
            return;
          }

          if (message is SettingPrinterMessage) {
            replyPort = message.sendPort;
            final isReady = _checkSettingPrinter(bindings);
            logger.i('_printEntry SettingPrinterMessage: $isReady');
            replyPort.send({'isReady': isReady});
            return;
          }

          if (message is PrintStateMessage) {
            replyPort = message.sendPort;
            final printerLog = getPrinterLogData(bindings);
            logger.i('_printEntry PrintStateMessage: $printerLog');
            replyPort.send({'printStatus': printerLog});
            return;
          }

          if (message is PrintRibbonStatus) {
            replyPort = message.sendPort;
            final ribbonStatus = _getRibbonStatus(bindings);
            logger.i('_printEntry PrintRibbonStatus: $ribbonStatus');
            replyPort.send({'printRibbonStatus': ribbonStatus});
            return;
          }

          if (message is PrintMessage) {
            final printPath = message.printPath;
            final isSingleMode = message.isSingleMode;
            replyPort = message.sendPort;

            String? frontImageInfo;
            String? behindImageInfo;

            _checkFeeder(bindings);
            _checkCardInPrinter(bindings);

            logger.i('6. PrintStart');

            if (printPath.frontPath != null) {
              frontImageInfo = await drawImage(path: printPath.frontPath!, bindings: bindings);
            }

            logger.i('7. PrintStart frontImageInfo: $frontImageInfo');

            if (printPath.backPath != null) {
              behindImageInfo = await drawImage(path: printPath.backPath!, bindings: bindings, isFront: false);
              // ❗️ 프로세스 충돌 발생, 파일을 삭제해야 됨.
              await File(printPath.backPath!).delete().catchError((_) {
                logger.i('Failed to delete rotated rear image');
              });
            }

            logger.i('8. PrintStart behindImageInfo: $behindImageInfo');

            logger.i('9. Injecting card...');
            bindings.injectCard();

            logger.i('10. Printing card... isSingleMode: $isSingleMode');
            if (isSingleMode) {
              bindings.printCard(
                frontImageInfo: behindImageInfo,
                backImageInfo: null,
              );
            } else {
              bindings.printCard(
                frontImageInfo: frontImageInfo,
                backImageInfo: behindImageInfo,
              );
            }

            logger.i('7. Ejecting card...');
            bindings.ejectCard();

            final printerLog = getPrinterLogData(bindings);

            replyPort.send({'printStatus': printerLog, 'error': ''});
          }
        } catch (e) {
          logger.i('isolateReceivePort: $e');
          replyPort?.send({'printStatus': PrinterLog(), 'error': e.toString()});
        }
      });
    } catch (e) {
      rethrow;
    }
  }

  void _checkFeeder(PrinterBindings bindings) {
    logger.i('Checking feeder status...');
    final hasCard = bindings.checkFeederStatus();
    if (!hasCard) {
      throw Exception('Card feeder is empty');
    }
  }

  void _checkCardInPrinter(PrinterBindings bindings) {
    logger.i('Checking card in printer...');
    final isCardInPrinter = bindings.checkCardPosition();
    if (isCardInPrinter) {
      logger.i('Card found, ejecting...');
      bindings.ejectCard();
    }
  }

  Future<bool> checkConnectedPrint() async {
    try {
      final responsePort = ReceivePort();

      _sendPort.send(
        ConnectMessage(
          sendPort: responsePort.sendPort,
        ),
      );

      final response = await responsePort.first as Map<String, dynamic>;
      final isConnected = response['isConnected'] as bool;

      return isConnected;
    } catch (e) {
      logger.e('Error checking printer connection: $e');
      return false;
    }
  }

  Future<bool> _checkConnectedPrint(PrinterBindings bindings) async {
    try {
      int result = bindings.connectPrinter();

      if (result != 0) {
        logger.e('Printer connection failed with code: $result');
        return false;
      }

      logger.e('checkConnectedPrint: $result');

      final printerLog = getPrinterLogData(bindings);

      final isReady = printerLog?.printerMainStatusCode == "1004";

      return result == 0 && isReady;
    } catch (e) {
      logger.e('Error checking printer connection: $e');
      return false;
    }
  }

  Future<bool> checkSettingPrinter() async {
    try {
      final responsePort = ReceivePort();

      _sendPort.send(
        SettingPrinterMessage(
          sendPort: responsePort.sendPort,
        ),
      );

      final response = await responsePort.first as Map<String, dynamic>;
      final isConnected = response['isReady'] as bool;

      return isConnected;
    } catch (e) {
      logger.e('Error checking printer connection: $e');
      return false;
    }
  }

  bool _checkSettingPrinter(PrinterBindings bindings) {
    try {
      // 3. 리본 설정
      // 레거시 코드와 동일하게 setRibbonOpt 호출
      bindings.setRibbonOpt(1, 0, "2", 2);
      bindings.setRibbonOpt(1, 1, "255", 4);

      // 4. 프린터 준비 상태 확인
      final ready = bindings.ensurePrinterReady();
      if (!ready) {
        throw Exception('Failed to ensure printer ready');
      }
      return true;
    } catch (e) {
      logger.e('Error settingPrinter: $e');
      return false;
    }
  }

  Future<PrinterLog?> startPrint({
    required File? frontFile,
    required File? embeddedFile,
    required bool isSingleMode,
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

      _sendPort.send(
        PrintMessage(
          isSingleMode: isSingleMode,
          printPath: PrintPath(frontPath: frontPath, backPath: rotatedRearPath),
          sendPort: responsePort.sendPort,
        ),
      );

      final response = await responsePort.first as Map<String, dynamic>;
      final printStatus = response['printStatus'] as PrinterLog?;
      final errorMsg = response['error'] as String;

      if (errorMsg.isEmpty) {
        return printStatus;
      } else {
        Exception(errorMsg);
      }

      return null;
    } catch (e, stack) {
      logger.i('error: $e stack: $stack');
      rethrow;
    }
  }

  Future<void> _initializePrinter(PrinterBindings bindings) async {
    try {
      logger.i('1. Initializing printer...');

      // 1. 프린터 라이브러리 초기화
      logger.i('2. Initializing printer library...');
      bindings.clearLibrary();

      logger.i('3. Printer library initialized');
      bindings.initLibrary();

      // 2. 프린터 밝기 설정 변경
      try {
        logger.i('4. Image brightness set to 0');

        bindings.setImageVisualParameters(
          brightness: 5,
          contrast: 0,
          saturation: 0,
        );
      } catch (e) {
        logger.e('Error setting image brightness: $e');
      }

      logger.i('5. Printer initialization completed');
    } catch (e, stack) {
      logger.i('Printer initialization error: $e');
      Error.throwWithStackTrace(
        Exception('Printer initialization error: $e'),
        stack,
      );
    }
  }

  Future<PrinterLog?> startLog() async {
    try {
      final responsePort = ReceivePort();

      _sendPort.send(
        PrintStateMessage(sendPort: responsePort.sendPort),
      );

      final response = await responsePort.first as Map<String, dynamic>;

      return response['printStatus'] as PrinterLog;
    } catch (e, stack) {
      logger.i('startLog error: $e\nStack: $stack');
      return null;
    }
  }

  Future<RibbonStatus> getRibbonStatus() async {
    try {
      final responsePort = ReceivePort();

      _sendPort.send(
        PrintRibbonStatus(sendPort: responsePort.sendPort),
      );

      final response = await responsePort.first as Map<String, dynamic>;

      return response['printRibbonStatus'] as RibbonStatus;
    } catch (e) {
      logger.e('Error getting ribbon status: $e');
      return RibbonStatus(rbnRemaining: 0, filmRemaining: 0);
    }
  }

  RibbonStatus _getRibbonStatus(PrinterBindings bindings) {
    try {
      final ribbonStatus = bindings.getRbnAndFilmRemaining();
      if (ribbonStatus != null) {
        logger.i('Ribbon remaining: ${ribbonStatus.rbnRemaining}%, Film remaining: ${ribbonStatus.filmRemaining}%');
        return ribbonStatus;
      } else {
        logger.w('Ribbon status is null');
        return RibbonStatus(rbnRemaining: 0, filmRemaining: 0);
      }
    } catch (e) {
      logger.e('Error getting ribbon status: $e');
      return RibbonStatus(rbnRemaining: 0, filmRemaining: 0);
    }
  }

  PrinterLog? getPrinterLogData(PrinterBindings bindings) {
    try {
      final printerStatus = bindings.getPrinterStatus();
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
      logger.i(e);
      return null;
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

  Future<String> drawImage({required String path, required PrinterBindings bindings, bool isFront = true}) async {
    StringBuffer buffer = StringBuffer();
    try {
      await _prepareAndDrawImage(path, true, bindings);

      logger.i('Committing canvas...');
      buffer.write(_commitCanvas(bindings));

      return buffer.toString();
    } catch (e, stack) {
      logger.i('Error in front canvas preparation: $e\nStack: $stack');
      throw Exception('Failed to prepare ${isFront ? 'Front' : 'Back'} canvas: $e');
    }
  }

  Future<void> _prepareAndDrawImage(String imagePath, bool isFront, PrinterBindings bindings) async {
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
