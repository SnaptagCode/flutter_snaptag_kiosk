import 'package:flutter_snaptag_kiosk/core/common/constants/alert_key.dart';
import 'package:flutter_snaptag_kiosk/domain/repositories/i_event_preview_repository.dart';
import 'package:flutter_snaptag_kiosk/domain/services/i_slack_log_service.dart';

class RefreshEventPreviewUseCase {
  final IEventPreviewRepository _repository;
  final ISlackLogService _slackLog;

  RefreshEventPreviewUseCase(this._repository, this._slackLog);

  Future<void> call({
    required int machineId,
    required String deviceUUID,
  }) async {
    await _repository.createUniqueKeyHistory(
      machineId: machineId.toString(),
      uniqueKey: deviceUUID,
    );

    _slackLog.sendBroadcastLogWithKey(InfoKey.inspectionStart.key);
  }
}
