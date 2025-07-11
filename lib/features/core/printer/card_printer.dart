import 'dart:ffi' as ffi; // ffi 임포트 확인
import 'dart:io';

import 'package:ffi/ffi.dart'; // Utf8 사용을 위한 임포트
import 'package:flutter_snaptag_kiosk/features/core/printer/printer_log.dart';
import 'package:flutter_snaptag_kiosk/features/core/printer/isolate/printer_manager.dart';
import 'package:flutter_snaptag_kiosk/features/core/printer/ribbon_status.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';

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
      final machineId = ref.read(kioskInfoServiceProvider)?.kioskMachineId ?? 0;
      SlackLogService().sendLogToSlack('Machine ID: $machineId, Printer error: $e');
      return false;
    }
  }

  Future<bool> checkSettingPrinter() async {
    try {
      final printerManager = await PrinterManager.getInstance();
      final isSetting = await printerManager.checkSettingPrinter();

      return isSetting;
    } catch (e) {
      final machineId = ref.read(kioskInfoServiceProvider)?.kioskMachineId ?? 0;
      SlackLogService().sendLogToSlack('*[MachineId : $machineId]* \n printerError: $e');
      return false;
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

  Future<RibbonStatus> getRibbonStatus() async {
    try {
      final printerManager = await PrinterManager.getInstance();
      return await printerManager.getRibbonStatus();
    } catch (e) {
      final machineId = ref.read(kioskInfoServiceProvider)?.kioskMachineId ?? 0;
      SlackLogService().sendLogToSlack('*[MachineId : $machineId]* \n printerError: $e');
      rethrow;
    }
  }

  Future<void> printImage({
    required File? frontFile,
    required File? backFile,
  }) async {
    try {
      state = const AsyncValue.loading();
      final isSingleMode = (ref.read(pagePrintProvider) == PagePrintType.single);
      final printerManager = await PrinterManager.getInstance();

      final printerLog =
          await printerManager.startPrint(isSingleMode: isSingleMode, frontFile: frontFile, embeddedFile: backFile);

      await _printerStateLog(printerLog);
    } catch (e) {
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
}
