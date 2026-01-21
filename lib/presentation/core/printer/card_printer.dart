// ffi 임포트 확인
import 'dart:io';

// Utf8 사용을 위한 임포트
import 'package:flutter_snaptag_kiosk/core/data/datasources/cache/kiosk_info_service.dart';
import 'package:flutter_snaptag_kiosk/core/data/datasources/remote/slack_log_service.dart';
import 'package:flutter_snaptag_kiosk/core/data/repositories/kiosk_repository.dart';
import 'package:flutter_snaptag_kiosk/presentation/core/printer/isolate/printer_manager.dart';
import 'package:flutter_snaptag_kiosk/presentation/core/printer/printer_log.dart';
import 'package:flutter_snaptag_kiosk/presentation/core/printer/ribbon_status.dart';
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

      return isConnected;
    } catch (e) {
      return false;
    }
  }

  Future<bool> checkSettingPrinter() async {
    try {
      final printerManager = await PrinterManager.getInstance();
      final isSetting = await printerManager.checkSettingPrinter();

      return isSetting;
    } catch (e) {
      return false;
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
      final machineId = ref.read(kioskInfoServiceProvider)?.kioskMachineId ?? 0;
      SlackLogService().sendLogToSlack('*[MachineId : $machineId]* \n printerError: $e');
      rethrow;
    }
  }

  Future<void> _printerStateLog(PrinterLog? printerLog) async {
    try {
      if (printerLog != null) {
        final machineId = ref.read(kioskInfoServiceProvider)?.kioskMachineId ?? 0;
        final log = printerLog.copyWith(kioskMachineId: machineId);
        if (machineId != 0) {
          await ref.read(kioskRepositoryProvider).updatePrintLog(request: log);
          SlackLogService().sendLogToSlack('PrintState : $log');
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> printImage({
    required File? frontFile,
    required File? embeddedFile,
    required bool isSingleMode,
  }) async {
    try {
      state = const AsyncValue.loading();
      final printerManager = await PrinterManager.getInstance();
      final isMetal = ref.read(kioskInfoServiceProvider)?.isMetal == true ? true : false;

      await printerManager.startPrint(
          isSingleMode: isSingleMode, frontFile: frontFile, embeddedFile: embeddedFile, isMetal: isMetal);

      // 프린트 성공 시 상태를 완료로 변경
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      // 프린트 실패 시 에러 상태로 변경
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }
}
