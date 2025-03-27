import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:ffi' as ffi; // ffi 임포트 확인
import 'dart:isolate';
import 'dart:typed_data';
import 'package:ffi/ffi.dart'; // Utf8 사용을 위한 임포트
import 'package:flutter_snaptag_kiosk/features/core/printer/print_path.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:image/image.dart' as img;

class PrinterManager {
  static PrinterManager? _instance;
  late PrinterBindings _bindings;
  late Isolate _printIsolate;
  late SendPort _sendPort;
  bool isFirst = false;

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
      logger.i('_initPrintIsolate');
      final printReceivePort = ReceivePort();

      _printIsolate = await Isolate.spawn(_printEntry, printReceivePort.sendPort);

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

      // 1. 라이브러리 초기화
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

      // 피더 상태 체크 추가
      logger.i('Checking feeder status...');
      final hasCard = bindings.checkFeederStatus();
      if (!hasCard) {
        throw Exception('Card feeder is empty');
      }

      // compute(, 'message');

      logger.i('1. Checking card position...');
      final hasCardInPrinter = bindings.checkCardPosition();
      if (hasCardInPrinter) {
        logger.i('Card found, ejecting...');
        bindings.ejectCard();
      }

      isolateReceivePort.listen((message) async {
        if (message is Map<String, dynamic>) {
          final printPath = message['data'] as PrintPath;
          final replyPort = message['port'] as SendPort;

          logger.i('printPath: front ${printPath.frontPath} back ${printPath.backPath} replyPort: $replyPort');

          try {
            // 프린트 작업

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

            logger.i('7. Ejecting card...');
            bindings.ejectCard();

            replyPort.send({'status': 'success'});
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

  Future<void> startPrint({
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

      final response = await responsePort.first as Map<String, dynamic>;

      logger.i('response: $response');
      if (response['status'] == 'success') {
        logger.i('프린트 완료');
      } else {
        logger.i('프린트 실패');
      }
    } catch (e, stack) {
      logger.i('error: $e stack: $stack');
    }
  }

  Future<void> _initializePrinter() async {
    try {
      _bindings.initLibrary();

      printStatus();

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

  void printStatus() {
    final status = _bindings.getPrinterStatus();
    if (status != null) {
      logger.i(
          'status mainCode ${status.mainCode} mainStatus ${status.mainStatus} errorStatus ${status.errorStatus} subCode ${status.subCode} wariningStatus ${status.warningStatus}');
    } else {
      logger.i('status null');
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

      _bindings = PrinterBindings();
      _initializePrinter();

      // 피더 상태 체크 추가
      logger.i('Checking feeder status...');
      final hasCard = _bindings.checkFeederStatus();
      if (!hasCard) {
        throw Exception('Card feeder is empty');
      }

      // compute(, 'message');

      logger.i('1. Checking card position...');
      final hasCardInPrinter = _bindings.checkCardPosition();
      if (hasCardInPrinter) {
        logger.i('Card found, ejecting...');
        _bindings.ejectCard();
      }

      logger.i('2. Preparing front canvas...');
      StringBuffer? frontBuffer;

      if (frontFile != null) {
        frontBuffer = StringBuffer();
        try {
          await _prepareAndDrawImage(frontBuffer, frontFile.path, true);
        } catch (e, stack) {
          logger.i('Error in front canvas preparation: $e\nStack: $stack');
          throw Exception('Failed to prepare front canvas: $e');
        }
      }

      StringBuffer? rearBuffer;

      if (embeddedFile != null) {
        logger.i('3. Loading and rotating rear image...');
        final rearImage = await embeddedFile.readAsBytes();
        final rotatedRearImage = _bindings.flipImage180(rearImage);
        // 임시 파일로 저장
        final temp = DateTime.now().millisecondsSinceEpoch.toString();
        final rotatedRearPath = '${temp}_rotated.png';
        await File(rotatedRearPath).writeAsBytes(rotatedRearImage);

        try {
          logger.i('4. Preparing rear canvas...');
          rearBuffer = StringBuffer();

          try {
            await _prepareAndDrawImage(rearBuffer, rotatedRearPath, false);
          } catch (e, stack) {
            logger.i('Error in rear canvas preparation: $e\nStack: $stack');
            throw Exception('Failed to prepare rear canvas: $e');
          }
        } finally {
          await File(rotatedRearPath).delete().catchError((_) {
            logger.i('Failed to delete rotated rear image');
          });
        }
      }

      logger.i('5. Injecting card...');
      _bindings.injectCard();

      logger.i('6. Printing card...');
      _bindings.printCard(
        frontImageInfo: frontBuffer?.toString(),
        backImageInfo: rearBuffer?.toString(),
      );

      logger.i('7. Ejecting card...');
      _bindings.ejectCard();

      _bindings.clearLibrary();
    } catch (e, stack) {
      logger.i('Print error: $e\nStack: $stack');
      rethrow;
    }
  }

  Future<void> printImageTest({
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

      // await IsolateManager<PrintPath, void>()
      //     .runInIsolate(_printImageIsolate, PrintPath(frontPath: frontPath, backPath: rotatedRearPath));

      _printImageIsolate(PrintPath(frontPath: frontPath, backPath: null));
    } catch (e, stack) {
      logger.i('Print error: $e\nStack: $stack');
    }
  }

  Future<void> _printImageIsolate(PrintPath printPath) async {
    try {
      // ❗️ DynamicLibrary 를 Isolate 안에서 생성해야 함.
      _bindings = PrinterBindings();

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

      String? frontImageInfo;
      String? behindImageInfo;

      if (printPath.frontPath != null) {
        frontImageInfo = await drawImage(path: printPath.frontPath!, bindings: _bindings);
      }

      if (printPath.backPath != null) {
        behindImageInfo = await drawImage(path: printPath.backPath!, bindings: _bindings);
        // ❗️ 프로세스 충돌 발생, 파일을 삭제해야 됨.
        await File(printPath.backPath!).delete().catchError((_) {
          logger.i('Failed to delete rotated rear image');
        });
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
      rethrow;
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

  Future<void> _prepareAndDrawImage(StringBuffer buffer, String imagePath, bool isFront) async {
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
    // buffer.write(_commitCanvas());
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
