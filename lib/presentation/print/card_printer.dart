import 'dart:io';

import 'package:flutter_snaptag_kiosk/core/common/logger/logger_service.dart';
import 'package:flutter_snaptag_kiosk/domain/domain.dart';
import 'package:flutter_snaptag_kiosk/presentation/core/card_count_provider.dart';
import 'package:flutter_snaptag_kiosk/presentation/core/printer_log_provider.dart';
import 'package:flutter_snaptag_kiosk/presentation/kiosk_shell/kiosk_info_service.dart';
import 'package:flutter_snaptag_kiosk/presentation/core/slack_log_provider.dart';
import 'package:flutter_snaptag_kiosk/data/repositories/kiosk_repository.dart';
import 'package:flutter_snaptag_kiosk/presentation/print/di/print_di.dart';
import 'package:flutter_snaptag_kiosk/presentation/print/luca/state/printer_log.dart';
import 'package:flutter_snaptag_kiosk/presentation/print/luca/state/ribbon_status.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'card_printer.g.dart';

@Riverpod(keepAlive: true)
class PrinterService extends _$PrinterService implements IPrinterService {
  @override
  FutureOr<void> build() async {}

  Future<bool> connectedPrinter() async {
    try {
      return await ref.read(printerRepositoryProvider).checkConnection();
    } catch (e) {
      return false;
    }
  }

  Future<bool> checkSettingPrinter() async {
    try {
      return await ref.read(printerRepositoryProvider).checkSetting();
    } catch (e) {
      return false;
    }
  }

  Future<void> checkFeeder() async {
    try {
      await ref.read(printerRepositoryProvider).checkFeeder();
    } catch (e) {
      rethrow;
    }
  }

  Future<RibbonStatus> getRibbonStatus() async {
    try {
      return await ref.read(printerRepositoryProvider).getRibbonStatus();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> printerStateLog() async {
    try {
      final printerLog = await ref.read(printerRepositoryProvider).getStateLog();

      await _printerStateLog(printerLog);
    } catch (e) {
      final machineName = ref.read(kioskInfoServiceProvider)?.kioskMachineName ?? '-';
      ref.read(slackLogServiceProvider).sendLog('*[$machineName]* \n printerError: $e');
      rethrow;
    }
  }

  Future<void> _printerStateLog(PrinterLog? printerLog) async {
    try {
      if (printerLog != null) {
        final machineId = ref.read(kioskInfoServiceProvider)?.kioskMachineId ?? 0;
        final cardCountState = ref.read(cardCountProvider);
        final log = printerLog.copyWith(
          kioskMachineId: machineId,
          remainingSingleSidedCountPre: cardCountState.currentCount.toString(),
          remainingSingleSidedCountPost: cardCountState.initialCount.toString(),
        );
        if (machineId != 0) {
          await ref.read(kioskRepositoryProvider).updatePrintLog(request: log);
          ref.read(printerLogProvider.notifier).update(log);
          ref.read(slackLogServiceProvider).sendLog('PrintState : $log');
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> printImage({
    required File? frontFile,
    required File? embeddedFile,
    required bool isSingleMode,
  }) async {
    try {
      state = const AsyncValue.loading();
      final isMetal = ref.read(kioskInfoServiceProvider)?.isMetal == true ? true : false;

      final printerLog = await ref.read(printerRepositoryProvider).executePrint(
            isSingleMode: isSingleMode,
            frontFile: frontFile,
            embeddedFile: embeddedFile,
            isMetal: isMetal,
          );

      await _updatePrintStatusAndCheckKioskAlive(printerLog);
      // 프린트 성공 시 상태를 완료로 변경
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      // 프린트 실패 시 에러 상태로 변경
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  Future<void> _updatePrintStatusAndCheckKioskAlive(PrinterLog? printerLog) async {
    try {
      final machineId = ref.read(kioskInfoServiceProvider)?.kioskMachineId ?? 0;

      if (machineId != 0 && printerLog != null) {
        final kioskEventId = ref.read(kioskInfoServiceProvider)?.kioskEventId ?? 0;
        final cardCountState = ref.read(cardCountProvider);
        final log = printerLog.copyWith(
          kioskMachineId: machineId,
          remainingSingleSidedCountPre: cardCountState.currentCount.toString(),
          remainingSingleSidedCountPost: cardCountState.initialCount.toString(),
        );
        ref.read(printerLogProvider.notifier).update(log);
        await ref.read(kioskRepositoryProvider).updatePrintLog(request: log);
        if (kioskEventId != 0) {
          try {
            await ref.read(kioskRepositoryProvider).checkKioskAlive(
                  kioskEventId: kioskEventId,
                  machineId: machineId,
                  remainingSingleSidedCount: cardCountState.remainingSingleSidedCount,
                );
          } catch (e) {
            ref.read(slackLogServiceProvider).sendErrorLog('CardPrinter.printImage checkKioskAlive failure: $e');
            logger.e('CardPrinter.printImage checkKioskAlive failure', error: e);
          }
        }
      }
    } catch (e) {
      ref.read(slackLogServiceProvider).sendErrorLog('CardPrinter.printImage _updatePrintStatusAndCheckKioskAlive failure: $e');
      logger.e('CardPrinter.printImage _updatePrintStatusAndCheckKioskAlive failure', error: e);
    }
  }
}
