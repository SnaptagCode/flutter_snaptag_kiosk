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

      await printerStartLog(machineId);

      return response;
    } catch (e) {
      ref.invalidateSelf();
      rethrow;
    }
  }

  Future<void> printerStartLog(int machineId) async {
    try {
      final printerManager = await PrinterManager.getInstance();
      final printerLog = await printerManager.startLog();

      if (printerLog != null) {
        final log = printerLog.copyWith(kioskMachineId: machineId);
        if (machineId != 0) {
          await ref.read(kioskRepositoryProvider).updatePrintLog(request: log);
          SlackLogService().sendLogToSlack('PrintState : $log');
        }
      }
    } catch (e) {
      // TODO : 프린트 초기화 작업 중 오류 발생.
      logger.i(e);
      SlackLogService().sendLogToSlack('printerStartLog : $e');
    }
  }

  /// 새로운 머신 ID로 업데이트 후 새로고침
  Future<void> refreshWithMachineId(int machineId) async {
    state = await _fetchAndUpdateKioskInfo(machineId: machineId);
  }
}
