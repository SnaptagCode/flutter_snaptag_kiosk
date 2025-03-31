import 'dart:io';

// Utf8 사용을 위한 임포트
import 'package:flutter_snaptag_kiosk/data/datasources/cache/kiosk_info_service.dart';
import 'package:flutter_snaptag_kiosk/data/datasources/remote/slack_log_service.dart';
import 'package:flutter_snaptag_kiosk/data/repositories/kiosk_repository.dart';
import 'package:flutter_snaptag_kiosk/features/core/printer/printer_manager.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'card_printer.g.dart';

@Riverpod(keepAlive: true)
class PrinterService extends _$PrinterService {
  @override
  FutureOr<void> build() async {}

  Future<void> printImage({
    required File? frontFile,
    required File? backFile,
  }) async {
    try {
      state = const AsyncValue.loading();

      final printerManager = await PrinterManager.getInstance();

      final printerLog = await printerManager.startPrint(frontFile: frontFile, embeddedFile: backFile);

      if (printerLog != null) {
        final machineId = ref.read(kioskInfoServiceProvider)?.kioskMachineId ?? 0;
        final log = printerLog.copyWith(kioskMachineId: machineId);
        if (machineId != 0) {
          await ref.read(kioskRepositoryProvider).updatePrintLog(request: log);
          SlackLogService().sendLogToSlack('PrintState : $log');
        }
      }
    } catch (e) {
      SlackLogService().sendLogToSlack('printerError: $e');
      rethrow;
    }
  }
}
