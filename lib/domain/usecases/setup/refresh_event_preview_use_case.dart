import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_snaptag_kiosk/core/common/constants/alert_key.dart';
import 'package:flutter_snaptag_kiosk/domain/services/i_slack_log_service.dart';
import 'package:flutter_snaptag_kiosk/presentation/kiosk_shell/kiosk_info_service.dart';
import 'package:flutter_snaptag_kiosk/presentation/setup/uuid_provider.dart';
import 'package:flutter_snaptag_kiosk/domain/repositories/i_event_preview_repository.dart';

class RefreshEventPreviewUseCase {
  final Ref _ref;
  final IEventPreviewRepository _repository;
  final ISlackLogService _slackLog;

  RefreshEventPreviewUseCase(this._ref, this._repository, this._slackLog);

  Future<void> execute(int machineId) async {
    final deviceUUID = await _ref.read(deviceUuidProvider.future);

    await _ref.read(kioskInfoServiceProvider.notifier).refreshWithMachineId(machineId);

    await _repository.createUniqueKeyHistory(
      machineId: machineId.toString(),
      uniqueKey: deviceUUID,
    );

    _slackLog.sendBroadcastLogWithKey(InfoKey.inspectionStart.key);
  }
}
