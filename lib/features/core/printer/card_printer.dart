import 'dart:ffi' as ffi; // ffi 임포트 확인
import 'dart:io';

import 'package:ffi/ffi.dart'; // Utf8 사용을 위한 임포트
import 'package:flutter/foundation.dart';
import 'package:flutter_snaptag_kiosk/core/utils/logger_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'printer_bindings.dart';

part 'card_printer.g.dart';

@Riverpod(keepAlive: true)
class PrinterService extends _$PrinterService {
  late final PrinterBindings _bindings;

  @override
  FutureOr<void> build() async {
    _bindings = PrinterBindings();
    await _initializePrinter();
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

      state = const AsyncValue.loading();
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
    } catch (e, stack) {
      logger.i('Print error: $e\nStack: $stack');
      rethrow;
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

    logger.i('Committing canvas...');
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
