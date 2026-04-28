// ffi 임포트 확인
import 'dart:io';

// Utf8 사용을 위한 임포트
import 'package:flutter_snaptag_kiosk/core/common/log/app_log_service.dart';
import 'package:flutter_snaptag_kiosk/core/common/logger/logger_service.dart';
import 'package:flutter_snaptag_kiosk/presentation/core/printer_log_provider.dart';
import 'package:flutter_snaptag_kiosk/presentation/kiosk_shell/kiosk_info_service.dart';
import 'package:flutter_snaptag_kiosk/core/data/datasources/remote/slack_log_service.dart';
import 'package:flutter_snaptag_kiosk/presentation/print/isolate/printer_manager.dart';
import 'package:flutter_snaptag_kiosk/presentation/print/luca/state/printer_log.dart';
import 'package:flutter_snaptag_kiosk/presentation/print/luca/state/ribbon_status.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'card_printer.g.dart';

@Riverpod(keepAlive: true)
class PrinterService extends _$PrinterService {
  @override
  FutureOr<void> build() async {}

  Future<bool> connectedPrinter() async {
    try {
      final printerManager = await PrinterManager.getInstance();
      final isConnected = await printerManager.checkConnectedPrint();
      AppLogService.instance.device('프린터 연결 확인: $isConnected');
      return isConnected;
    } catch (e) {
      AppLogService.instance.device('프린터 연결 확인 실패: $e');
      return false;
    }
  }

  Future<bool> checkSettingPrinter() async {
    try {
      final printerManager = await PrinterManager.getInstance();
      final isSetting = await printerManager.checkSettingPrinter();
      AppLogService.instance.device('프린터 설정 확인: $isSetting');
      return isSetting;
    } catch (e) {
      AppLogService.instance.device('프린터 설정 확인 실패: $e');
      return false;
    }
  }

  Future<void> checkFeeder() async {
    try {
      final printerManager = await PrinterManager.getInstance();
      AppLogService.instance.device('피더 체크 시작');
      await printerManager.checkFeeder();
      AppLogService.instance.device('피더 체크 완료');
    } catch (e) {
      AppLogService.instance.device('피더 체크 실패: $e');
      rethrow;
    }
  }

  Future<RibbonStatus> getRibbonStatus() async {
    try {
      final printerManager = await PrinterManager.getInstance();
      return await printerManager.getRibbonStatus();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> printerStateLog() async {
    try {
      final printerManager = await PrinterManager.getInstance();

      final printerLog = await printerManager.startLog();

      await _printerStateLog(printerLog);
    } catch (e) {
      final machineName = ref.read(kioskInfoServiceProvider)?.kioskMachineName ?? '-';
      SlackLogService().sendLogToSlack('*[$machineName]* \n printerError: $e');
      rethrow;
    }
  }

  Future<void> _printerStateLog(PrinterLog? printerLog) async {
    if (printerLog != null) {
      final machineId = ref.read(kioskInfoServiceProvider)?.kioskMachineId ?? 0;
      final log = printerLog.copyWith(kioskMachineId: machineId);
      if (machineId != 0) {
        ref.read(printerLogProvider.notifier).update(log);
        AppLogService.instance.info('PrintState : $log');
      }
    }
  }

  Future<void> printImage({
    required File? frontFile,
    required File? embeddedFile,
    required bool isSingleMode,
  }) async {
    try {
      state = const AsyncValue.loading();
      final frontName = frontFile != null ? frontFile.path.split(RegExp(r'[/\\]')).last : 'null';
      final backName = embeddedFile != null ? embeddedFile.path.split(RegExp(r'[/\\]')).last : 'null';
      AppLogService.instance.device('인쇄 시작: mode=${isSingleMode ? "단면" : "양면"} front=$frontName back=$backName');
      final printerManager = await PrinterManager.getInstance();
      final isMetal = ref.read(kioskInfoServiceProvider)?.isMetal == true ? true : false;

      final printerLog = await printerManager.startPrint(
          isSingleMode: isSingleMode, frontFile: frontFile, embeddedFile: embeddedFile, isMetal: isMetal);

      await _updatePrintStatusAndCheckKioskAlive(printerLog);
      AppLogService.instance.device('인쇄 완료');
      // 프린트 성공 시 상태를 완료로 변경
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      AppLogService.instance.device('프린터 오류: $e');
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  Future<void> _updatePrintStatusAndCheckKioskAlive(PrinterLog? printerLog) async {
    try {
      final machineId = ref.read(kioskInfoServiceProvider)?.kioskMachineId ?? 0;
      if (machineId != 0 && printerLog != null) {
        final log = printerLog.copyWith(kioskMachineId: machineId);
        ref.read(printerLogProvider.notifier).update(log);
        AppLogService.instance.info('PrintState : $log');
      }
    } catch (e) {
      AppLogService.instance.error('CardPrinter.printImage _updatePrintStatusAndCheckKioskAlive failure: $e');
      logger.e('CardPrinter.printImage _updatePrintStatusAndCheckKioskAlive failure', error: e);
    }
  }
}
