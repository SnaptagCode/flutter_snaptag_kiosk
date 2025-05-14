import 'package:flutter_snaptag_kiosk/features/core/printer/printer_manager.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'kiosk_info_service.g.dart';

@Riverpod(keepAlive: true)
class KioskInfoService extends _$KioskInfoService {
  @override
  KioskMachineInfo? build() {
    return null;
  }

  Future<KioskMachineInfo> _fetchAndUpdateKioskInfo({int? machineId}) async {
    try {
      // kioskMachineId가 없는 경우 예외 발생
      if (machineId == null) {
        throw Exception('No kiosk machine id available');
      }
      state = KioskMachineInfo();
      // API를 통해 최신 정보 가져오기
      final kioskRepo = ref.read(kioskRepositoryProvider);

      final response = await kioskRepo.getKioskMachineInfo(
        machineId,
      );

      state = response;

      ref.read(frontPhotoListProvider.notifier).fetch();

      await SlackLogService().sendLogToSlack('printerStartLog_0'); //deleteP
      await printerStartLog(machineId);

      return response;
    } catch (e) {
      ref.invalidateSelf();
      rethrow;
    }
  }

  Future<void> printerStartLog(int machineId) async {
    try {
      await SlackLogService().sendLogToSlack('printerStartLog_1'); //deleteP

      final printerManager = await PrinterManager.getInstance();
      final printerLog = await printerManager.startLog();
      await SlackLogService().sendLogToSlack('printerStartLog_2'); //deleteP

      if (printerLog != null) {
        await SlackLogService().sendLogToSlack('printerStartLog_3'); //deleteP

        final log = printerLog.copyWith(kioskMachineId: machineId);
        if (machineId != 0) {
          await SlackLogService().sendLogToSlack('printerStartLog_4'); //deleteP

          await ref.read(kioskRepositoryProvider).updatePrintLog(request: log);
          await SlackLogService().sendLogToSlack('PrintState : $log');
        }
        await SlackLogService().sendLogToSlack('printerStartLog_5'); //deleteP

      }
    } catch (e) {
      // TODO : 프린트 초기화 작업 중 오류 발생.
      await SlackLogService().sendLogToSlack('printerStartLog : $e'); //deleteP
      logger.i(e);
    }
  }

  /// 새로운 머신 ID로 업데이트 후 새로고침
  Future<void> refreshWithMachineId(int machineId) async {
    state = await _fetchAndUpdateKioskInfo(machineId: machineId);
  }
}
