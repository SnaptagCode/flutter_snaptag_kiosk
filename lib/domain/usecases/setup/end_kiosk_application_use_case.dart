import 'package:flutter_snaptag_kiosk/domain/repositories/i_setup_repository.dart';
import 'package:flutter_snaptag_kiosk/domain/services/i_slack_log_service.dart';

class EndKioskApplicationUseCase {
  final ISetupRepository _repository;
  final ISlackLogService _slackLog;

  EndKioskApplicationUseCase(this._repository, this._slackLog);

  Future<void> call({
    required int kioskEventId,
    required int kioskMachineId,
    required String remainingSingleSidedCount,
  }) async {
    try {
      await _repository.endKioskApplication(
        kioskEventId: kioskEventId,
        machineId: kioskMachineId,
        remainingSingleSidedCount: remainingSingleSidedCount,
      );
    } catch (e) {
      _slackLog.sendErrorLog('End Kiosk Application: $e');
    }
  }
}
