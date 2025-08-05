import 'dart:ffi' as ffi; // ffi 임포트 확인
import 'dart:io';

import 'package:ffi/ffi.dart'; // Utf8 사용을 위한 임포트
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:flutter_snaptag_kiosk/features/core/printer/printer_log.dart';
import 'package:flutter_snaptag_kiosk/features/core/printer/ribbon_status.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';

import 'printer_bindings.dart';

part 'card_printer.g.dart';

@Riverpod(keepAlive: true)
class PrinterService extends _$PrinterService {
  late final PrinterBindings _bindings;

  bool _firstConnectedFailed = false;

  @override
  FutureOr<void> build() async {
    logger.i('Printer initialization..');
    _bindings = PrinterBindings();
    await _initializePrinter();
  }

  Future<void> _initializePrinter() async {
    try {
      // 1. 라이브러리 초기화 전에 이전 상태 정리
      _bindings.clearLibrary();

      _bindings.initLibrary();

      // 2. 프린터 밝기 설정 변경
      try {
        _bindings.setImageVisualParameters(
          brightness: 5,
          contrast: 0,
          saturation: 0,
        );
      } catch (e) {
        logger.e('Error setting image brightness: $e');
        SlackLogService().sendErrorLogToSlack('Error setting image brightness: $e');
      }

      // checkConnectedWithPrinterLog();

      // settingPrinter();
      final machineId = ref.read(kioskInfoServiceProvider)?.kioskMachineId ?? 0;
      logger.i('Machine ID: $machineId, Printer initialization completed');
    } catch (e) {
      final machineId = ref.read(kioskInfoServiceProvider)?.kioskMachineId ?? 0;

      SlackLogService().sendErrorLogToSlack('*[Machine ID: $machineId]*, Printer initialization error: $e');
      rethrow;
    }
  }

  Future<bool> checkConnectedPrint() async {
    try {
      final connected = _bindings.connectPrinter();
      logger.e('checkConnectedPrint: $connected');

      if (!connected) {
        if (!_firstConnectedFailed) {
          _firstConnectedFailed = true;
          SlackLogService().sendErrorLogToSlack('PrintConnected Failed - First Attempt');
        }
        return false;
      }

      final printerLog = getPrinterLogData(_bindings);

      final isReady = printerLog?.printerMainStatusCode == "1004";

      return connected && isReady;
    } catch (e) {
      logger.e('Error checking printer connection: $e');
      return false;
    }
  }

  RibbonStatus getRibbonStatus() {
    try {
      final ribbonStatus = _bindings.getRbnAndFilmRemaining();
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

  bool settingPrinter() {
    try {
      // 3. 리본 설정
      // 레거시 코드와 동일하게 setRibbonOpt 호출
      _bindings.setRibbonOpt(1, 0, "2", 2);
      _bindings.setRibbonOpt(1, 1, "255", 4);

      // 4. 프린터 준비 상태 확인
      final ready = _bindings.ensurePrinterReady();
      if (!ready) {
        throw Exception('Failed to ensure printer ready');
      }
      return true;
    } catch (e) {
      logger.e('Error settingPrinter: $e');
      return false;
    }
  }

  Future<void> printImage({
    required File? frontFile,
    required File? embeddedFile,
  }) async {
    try {
      /*if (frontFile == null && embeddedFile == null) {
        throw Exception('There is nothing to print');
      }*/
      final isSingleMode = (ref.read(pagePrintProvider) == PagePrintType.single);
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
            throw Exception('Failed to delete rotated rear image');
          });
        }
      }

      logger.i('5. Injecting card...');
      _bindings.injectCard();

      logger.i('6. Printing card...');

      if (isSingleMode) {
        _bindings.printCard(
          frontImageInfo: rearBuffer?.toString(),
          backImageInfo: null,
        );
      } else {
        _bindings.printCard(
          frontImageInfo: frontBuffer?.toString(),
          backImageInfo: rearBuffer?.toString(),
        );
      }

      logger.i('7. Ejecting card...');
      _bindings.ejectCard();

      // ❗️ 주석 처리된 부분은 나중에 필요할 때 활성화
      startPrintLog();
    } catch (e, stack) {
      logger.i('Print error: $e\nStack: $stack');
      rethrow;
    }
  }

  Future<PrinterLog?> startPrintLog() async {
    final printerLog = getPrinterLogData(_bindings);
    if (printerLog != null) {
      final machineId = ref.read(kioskInfoServiceProvider)?.kioskMachineId ?? 0;
      final log = printerLog.copyWith(kioskMachineId: machineId);
      if (machineId != 0) {
        await ref.read(kioskRepositoryProvider).updatePrintLog(request: log);
        SlackLogService().sendLogToSlack('Machine ID: $machineId , PrintState : $log');
      }
      return printerLog;
    }

    return null;
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
        throw Exception('Failed to commit canvas ($result)');
      }
      return strPtr.toDartString();
    } finally {
      calloc.free(strPtr);
      calloc.free(lenPtr);
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
}
