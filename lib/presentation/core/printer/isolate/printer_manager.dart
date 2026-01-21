import 'dart:async';
import 'dart:ffi' as ffi; // ffi 임포트 확인
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:ffi/ffi.dart'; // Utf8 사용을 위한 임포트
import 'package:flutter/services.dart';
import 'package:flutter_snaptag_kiosk/core/utils/logger_service.dart';
import 'package:flutter_snaptag_kiosk/presentation/core/printer/isolate/model/check_card_position_message.dart';
import 'package:flutter_snaptag_kiosk/presentation/core/printer/isolate/model/check_feeder_message.dart';
import 'package:flutter_snaptag_kiosk/presentation/core/printer/isolate/model/connect_message.dart';
import 'package:flutter_snaptag_kiosk/presentation/core/printer/isolate/model/draw_image_message.dart';
import 'package:flutter_snaptag_kiosk/presentation/core/printer/isolate/model/eject_message.dart';
import 'package:flutter_snaptag_kiosk/presentation/core/printer/isolate/model/inject_message.dart';
import 'package:flutter_snaptag_kiosk/presentation/core/printer/isolate/model/print_message.dart';
import 'package:flutter_snaptag_kiosk/presentation/core/printer/isolate/model/print_ribbon_status_message.dart';
import 'package:flutter_snaptag_kiosk/presentation/core/printer/isolate/model/print_state_message.dart';
import 'package:flutter_snaptag_kiosk/presentation/core/printer/isolate/model/setting_printer_message.dart';
import 'package:flutter_snaptag_kiosk/presentation/core/printer/isolate/print_path.dart';
import 'package:flutter_snaptag_kiosk/presentation/core/printer/printer_bindings.dart';
import 'package:flutter_snaptag_kiosk/presentation/core/printer/printer_log.dart';
import 'package:flutter_snaptag_kiosk/presentation/core/printer/ribbon_status.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

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
        try {
          final ob = message['object'];
          final replyPort = message['replyPort'] as SendPort;

          try {
            if (ob is ConnectMessage) {
              try {
                final isConnected = await _checkConnectedPrint(bindings);
                logger.i('_printEntry ConnectMessage: $isConnected');
                replyPort.send({'isConnected': isConnected, 'errorMsg': ''});
              } catch (e) {
                replyPort.send({'isConnected': false, 'errorMsg': e.toString()});
              }
              return;
            }

            if (ob is SettingPrinterMessage) {
              try {
                final isReady = _checkSettingPrinter(bindings);
                logger.i('_printEntry SettingPrinterMessage: $isReady');
                replyPort.send({'isReady': isReady, 'errorMsg': ''});
              } catch (e) {
                replyPort.send({'isReady': false, 'errorMsg': e.toString()});
              }
              return;
            }

            if (ob is PrintStateMessage) {
              try {
                final printerLog = _getPrinterLogData(bindings);
                logger.i('_printEntry PrintStateMessage: $printerLog');
                replyPort.send({'printerLog': printerLog, 'errorMsg': ''});
              } catch (e) {
                replyPort.send({'printerLog': null, 'errorMsg': e.toString()});
              }
              return;
            }

            if (ob is PrintRibbonStatusMessage) {
              try {
                final ribbonStatus = _getRibbonStatus(bindings);
                logger.i('_printEntry PrintRibbonStatus: $ribbonStatus');
                replyPort.send({'ribbonStatus': ribbonStatus, 'errorMsg': ''});
              } catch (e) {
                replyPort.send({'ribbonStatus': null, 'errorMsg': e.toString()});
              }
              return;
            }

            if (ob is CheckFeederMessage) {
              try {
                _checkFeeder(bindings);
                logger.i('_printEntry CheckFeederMessage: Feeder check passed');
                replyPort.send({'errorMsg': ''});
              } catch (e) {
                replyPort.send({'errorMsg': e.toString()});
              }
              return;
            }

            if (ob is CheckCardPositionMessage) {
              try {
                _checkCardInPrinter(bindings);
                logger.i('_printEntry CheckCardPositionMessage: Card check passed');
                replyPort.send({'errorMsg': ''});
              } catch (e) {
                replyPort.send({'errorMsg': e.toString()});
              }
              return;
            }

            if (ob is DrawImageMessage) {
              final path = ob.path;
              final isFront = ob.isFront;
              final isMetal = ob.isMetal;
              try {
                final imageBuffer = await drawImage(path: path, bindings: bindings, isFront: isFront, isMetal: isMetal);
                logger.i('DrawImageMessage imageBuffer: $imageBuffer');
                replyPort.send({'imageBuffer': imageBuffer, 'errorMsg': ''});
              } catch (e) {
                replyPort.send({'imageBuffer': null, 'errorMsg': e.toString()});
              }
              return;
            }

            if (ob is InjectMessage) {
              try {
                logger.i('Injecting card...');
                bindings.injectCard();
                replyPort.send({'errorMsg': ''});
              } catch (e) {
                replyPort.send({'errorMsg': e.toString()});
              }
              return;
            }

            if (ob is PrintMessage) {
              final printImageBuffer = ob.printPath;

              try {
                bindings.printCard(
                  frontImageInfo: printImageBuffer.frontBuffer,
                  backImageInfo: printImageBuffer.backBuffer,
                );

                replyPort.send({'errorMsg': ''});
              } catch (e) {
                replyPort.send({'error': e.toString()});
              }
              return;
            }

            if (ob is EjectMessage) {
              try {
                logger.i('Ejecting card...');
                bindings.ejectCard();
                replyPort.send({'errorMsg': ''});
              } catch (e) {
                replyPort.send({'errorMsg': e.toString()});
              }
              return;
            }
          } catch (e) {
            replyPort.send({'errorMsg': e.toString()});
          }
        } catch (e) {
          logger.i('isolateReceivePort: $e');
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
    final response = await _sendAndResponse(ConnectMessage());
    final isConnected = response['isConnected'] as bool;
    final errorMsg = response['errorMsg'] as String;

    if (errorMsg.isNotEmpty) {
      throw Exception(errorMsg);
    }

    return isConnected;
  }

  Future<bool> _checkConnectedPrint(PrinterBindings bindings) async {
    try {
      bool result = bindings.connectPrinter();

      if (!result) {
        logger.e('Printer connection failed with code: $result');
        return false;
      }

      final printerLog = _getPrinterLogData(bindings);

      final isReady = printerLog?.printerMainStatusCode == "1004";

      return result && isReady;
    } catch (e) {
      logger.e('Error checking printer connection: $e');
      return false;
    }
  }

  Future<bool> checkSettingPrinter() async {
    final response = await _sendAndResponse(SettingPrinterMessage());
    final isReady = response['isReady'] as bool;
    final errorMsg = response['errorMsg'] as String;

    if (errorMsg.isNotEmpty) {
      throw Exception(errorMsg);
    }

    return isReady;
  }

  bool _checkSettingPrinter(PrinterBindings bindings) {
    // 3. 리본 설정
    // 레거시 코드와 동일하게 setRibbonOpt 호출
    bindings.setRibbonOpt(1, 0, "2", 2);
    // bindings.setRibbonOpt(1, 1, "255", 4);

    // 4. 프린터 준비 상태 확인
    final ready = bindings.ensurePrinterReady();
    if (!ready) {
      throw Exception('Failed to ensure printer ready');
    }

    return true;
  }

  Future<PrinterLog?> startPrint({
    required File? frontFile,
    required File? embeddedFile,
    required bool isSingleMode,
    required bool isMetal,
  }) async {
    try {
      if (frontFile == null && embeddedFile == null) {
        throw Exception('There is nothing to print');
      }

      String? frontImageInfo;
      String? behindImageInfo;

      logger.i('6. Starting print process...');

      await _sendAndHandleResponse(CheckFeederMessage());

      logger.i('7. Checking Setting Card...');

      final ready = await checkSettingPrinter();

      if (ready) {
        logger.i('Printer is ready for printing');
      } else {
        throw Exception('Printer is not ready for printing');
      }

      logger.i('8. Preparing front image...');

      if (!isSingleMode && frontFile != null) {
        frontImageInfo =
            await _imageBufferResponse(DrawImageMessage(isFront: true, path: frontFile.path, isMetal: isMetal));
      }

      logger.i('9. Preparing back image...');

      if (embeddedFile != null) {
        final rotatedRearPath = await _rearImage(file: embeddedFile);
        behindImageInfo =
            await _imageBufferResponse(DrawImageMessage(isFront: false, path: rotatedRearPath, isMetal: isMetal));
      }

      logger.i('10. Preparing for printing...');

      await _sendAndHandleResponse(InjectMessage());

      logger.i('11. Injecting card completed');

      final buffer = isSingleMode
          ? PrintImageBuffer(frontBuffer: behindImageInfo, backBuffer: null)
          : PrintImageBuffer(frontBuffer: frontImageInfo, backBuffer: behindImageInfo);

      await _sendAndHandleResponse(PrintMessage(isSingleMode: isSingleMode, printPath: buffer));

      logger.i('13. Printing completed');

      await _sendAndHandleResponse(EjectMessage());

      logger.i('13. Ejecting card completed');

      final printerLog = await startLog();

      logger.i('14. Printer log $printerLog');

      return printerLog;
    } catch (e) {
      logger.i('error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> _sendAndResponse(Object object) async {
    final responsePort = ReceivePort();

    _sendPort.send({'object': object, 'replyPort': responsePort.sendPort});

    final response = await responsePort.first as Map<String, dynamic>;

    return response;
  }

  Future<String?> _imageBufferResponse(Object object) async {
    final response = await _sendAndResponse(object);
    final errorMsg = response['errorMsg'] as String;
    final imageBuffer = response['imageBuffer'] as String?;

    if (errorMsg.isNotEmpty) {
      throw Exception(errorMsg);
    }

    return imageBuffer;
  }

  Future<void> _sendAndHandleResponse(Object object) async {
    final response = await _sendAndResponse(object);
    final errorMsg = response['errorMsg'] as String;

    if (errorMsg.isNotEmpty) {
      throw Exception(errorMsg);
    }
  }

  Future<void> _initializePrinter(PrinterBindings bindings) async {
    try {
      logger.i('1. Initializing printer...');

      logger.i('2. Initializing printer library...');

      bindings.clearLibrary();

      logger.i('3. Printer library initialized');
      bindings.initLibrary();

      // 2. 프린터 밝기 설정 변경
      logger.i('4. Image brightness set to 0');

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
    final response = await _sendAndResponse(PrintStateMessage());
    final printerLog = response['printerLog'] as PrinterLog;
    final errorMsg = response['errorMsg'] as String;

    if (errorMsg.isNotEmpty) {
      throw Exception(errorMsg);
    }

    return printerLog;
  }

  Future<RibbonStatus> getRibbonStatus() async {
    final response = await _sendAndResponse(PrintRibbonStatusMessage());
    final ribbonStatus = response['ribbonStatus'] as RibbonStatus?;
    final errorMsg = response['errorMsg'] as String;

    if (errorMsg.isNotEmpty) {
      throw Exception(errorMsg);
    }

    return ribbonStatus ?? RibbonStatus(rbnRemaining: 0, filmRemaining: 0);
  }

  RibbonStatus _getRibbonStatus(PrinterBindings bindings) {
    final ribbonStatus = bindings.getRbnAndFilmRemaining();
    if (ribbonStatus != null) {
      logger.i('Ribbon remaining: ${ribbonStatus.rbnRemaining}%, Film remaining: ${ribbonStatus.filmRemaining}%');
      return ribbonStatus;
    } else {
      logger.w('Ribbon status is null');
      return RibbonStatus(rbnRemaining: 0, filmRemaining: 0);
    }
  }

  PrinterLog? _getPrinterLogData(PrinterBindings bindings) {
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

  Future<String> drawImage(
      {required String path, required PrinterBindings bindings, bool isFront = true, required bool isMetal}) async {
    StringBuffer buffer = StringBuffer();
    try {
      await _prepareAndDrawImage(path, true, bindings, isMetal);

      logger.i('Committing canvas...');
      buffer.write(_commitCanvas(bindings));

      return buffer.toString();
    } catch (e, stack) {
      logger.i('Error in front canvas preparation: $e\nStack: $stack');
      throw Exception('Failed to prepare ${isFront ? 'Front' : 'Back'} canvas: $e');
    } finally {
      if (!isFront) {
        // ❗️ 프로세스 충돌 발생, 파일을 삭제해야 됨.
        await File(path).delete().catchError((_) {
          logger.i('Failed to delete rotated rear image');
        });
      }
    }
  }

  Future<void> _prepareAndDrawImage(String imagePath, bool isFront, PrinterBindings bindings, bool isMetal) async {
    bindings.setCanvasOrientation(true);
    bindings.prepareCanvas(isColor: true);

    var pRibbonType = 0;
    try {
      pRibbonType = bindings.ribbonSettingsSW();
    } catch (e) {}
    var isYMCSK = pRibbonType == 25; // Metal
    final shouldPrintMetal = isYMCSK && isMetal;

    // Metal Settings..
    if (shouldPrintMetal) {
      bindings.setCoatingRegion(x: -1, y: -1, width: 56.0, height: 88.0, isFront: false, isErase: false);
    }

    logger.i('Drawing image...');
    bindings.drawImage(
      imagePath: imagePath,
      x: -1,
      y: -1,
      width: 56.0,
      height: 88.0,
      noAbsoluteBlack: true,
    );

    // Metal Settings..
    if (shouldPrintMetal) {
      final blackImg = await copyAssetPngToFile('assets/images/black_small.png');
      bindings.setImageParameters(transparency: 1, rotation: 0, scale: 0);
      bindings.setRibbonOpt(1, 0, "2", 2);
      bindings.drawWaterMark(blackImg);
    } else {
      bindings.setRibbonOpt(1, 0, "2", 2);
    }

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

  Future<String> copyAssetPngToFile(String assetPath, {String? outFileName}) async {
    // 1) 에셋 로드
    final ByteData data = await rootBundle.load(assetPath);
    final Uint8List bytes = data.buffer.asUint8List();

    // 2) 저장 위치 (임시 또는 앱 전용 디렉터리)
    final dir = await getTemporaryDirectory();
    final fileName = outFileName ?? assetPath.split('/').last;
    final file = File('${dir.path}/$fileName');

    // 3) 이미 있으면 덮어쓸지 여부 선택
    if (!await file.exists()) {
      await file.create(recursive: true);
    }
    await file.writeAsBytes(bytes, flush: true);

    return file.path; // 네이티브 API에 줄 수 있는 실제 경로
  }

  int getRibbonType(PrinterBindings bindings) {
    try {
      final pRibbonType = bindings.ribbonSettingsSW();
      return pRibbonType;
    } catch (e) {
      return 0;
    }
  }
}
