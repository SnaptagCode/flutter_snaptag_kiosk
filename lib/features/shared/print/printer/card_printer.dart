import 'dart:ffi' as ffi; // ffi 임포트 확인
import 'dart:io';

import 'package:ffi/ffi.dart'; // Utf8 사용을 위한 임포트
import 'package:flutter_snaptag_kiosk/core/utils/logger_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'printer_bindings.dart';

part 'card_printer.g.dart';

enum PrinterStatus { ready, busy, error }

@riverpod
class PrinterState extends _$PrinterState {
  late final PrinterBindings _bindings;

  @override
  FutureOr<PrinterStatus> build() async {
    _bindings = PrinterBindings();
    await _initializePrinter();
    return PrinterStatus.ready;
  }

  Future<void> _initializePrinter() async {
    try {
      // 1. 라이브러리 초기화 전에 이전 상태 정리
      _bindings.clearLibrary();

      // 2. 프린터 연결
      final connected = _bindings.connectPrinter();
      if (!connected) {
        throw Exception('Failed to connect printer');
      }
      logger.d('Printer connected successfully');

      // 3. 리본 설정
      // 레거시 코드와 동일하게 setRibbonOpt 호출
      _bindings.setRibbonOpt(1, 0, "2", 2);
      _bindings.setRibbonOpt(1, 1, "255", 4);

      // 4. 프린터 준비 상태 확인
      final ready = _bindings.ensurePrinterReady();
      if (!ready) {
        throw Exception('Failed to ensure printer ready');
      }

      logger.d('Printer initialization completed');
    } catch (e) {
      logger.d('Printer initialization error: $e');
      rethrow;
    }
  }

  Future<void> printImage({
    required String frontImagePath,
    required File embeddedFile,
  }) async {
    try {
      state = const AsyncValue.loading();

      logger.d('1. Checking card position...');
      final hasCard = _bindings.checkCardPosition();
      if (hasCard) {
        logger.d('Card found, ejecting...');
        _bindings.ejectCard();
      }

      logger.d('2. Preparing front canvas...');
      final frontBuffer = StringBuffer();
      /**
      try {
        await _prepareAndDrawImage(frontBuffer, frontImagePath, true);
      } catch (e, stack) {
        logger.d('Error in front canvas preparation: $e\nStack: $stack');
        throw Exception('Failed to prepare front canvas: $e');
      }
       */

      StringBuffer? rearBuffer;

      logger.d('3. Loading and rotating rear image...');
      final rearImage = await embeddedFile.readAsBytes();
      final rotatedRearImage = _bindings.flipImage180(rearImage);
      // 임시 파일로 저장
      final temp = DateTime.now().millisecondsSinceEpoch.toString();
      final rotatedRearPath = '${temp}_rotated.png';
      await File(rotatedRearPath).writeAsBytes(rotatedRearImage);

      try {
        logger.d('4. Preparing rear canvas...');
        rearBuffer = StringBuffer();
        /**
        try {
          await _prepareAndDrawImage(rearBuffer, rotatedRearPath, false);
        } catch (e, stack) {
          logger.d('Error in rear canvas preparation: $e\nStack: $stack');
          throw Exception('Failed to prepare rear canvas: $e');
        }
         */
      } finally {
        await File(rotatedRearPath).delete().catchError((_) {
          logger.d('Failed to delete rotated rear image');
        });
      }

      logger.d('5. Injecting card...');
      _bindings.injectCard();

      logger.d('6. Printing card...');
      _bindings.printCard(
        frontImageInfo: frontBuffer.toString(),
        backImageInfo: rearBuffer.toString(),
      );

      logger.d('7. Ejecting card...');
      _bindings.ejectCard();

      state = const AsyncValue.data(PrinterStatus.ready);
    } catch (e, stack) {
      logger.d('Print error: $e\nStack: $stack');
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> _prepareAndDrawImage(StringBuffer buffer, String imagePath, bool isFront) async {
    _bindings.setCanvasOrientation(true);
    _bindings.prepareCanvas(isColor: true);

    logger.d('Drawing image...');
    _bindings.drawImage(
      imagePath: imagePath,
      x: -1,
      y: -1,
      width: 56.0,
      height: 88.0,
      noAbsoluteBlack: true,
    );
    logger.d('Drawing empty text...');
    // 제거 시 이미지 출력이 안됨
    _bindings.drawText(
      text: '',
      x: 0,
      y: 0,
      width: 0,
      height: 0,
      noAbsoluteBlack: true,
    );
    logger.d('Committing canvas...');
    buffer.write(_commitCanvas());
  }

  // 프린터 상태 모니터링 메서드 추가
  Future<void> monitorPrinterStatus() async {
    while (state is AsyncData) {
      final status = _bindings.getPrinterStatus();
      if (status != null) {
        if (status.errorStatus != 0) {
          state = AsyncError('Printer error: ${status.errorStatus}', StackTrace.current);
          break;
        }
      }
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  String _commitCanvas() {
    final strPtr = calloc<ffi.Uint8>(200).cast<Utf8>();
    final lenPtr = calloc<ffi.Int32>()..value = 200;

    try {
      final result = _bindings.commitCanvas(strPtr, lenPtr);
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
