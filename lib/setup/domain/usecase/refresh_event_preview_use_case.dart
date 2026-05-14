import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_snaptag_kiosk/core/common/constants/alert_key.dart';
import 'package:flutter_snaptag_kiosk/data/datasources/remote/slack_log_service.dart';
import 'package:flutter_snaptag_kiosk/data/models/request/unique_key_request.dart';
import 'package:flutter_snaptag_kiosk/presentation/kiosk_shell/kiosk_info_service.dart';
import 'package:flutter_snaptag_kiosk/presentation/setup/uuid_provider.dart';
import 'package:flutter_snaptag_kiosk/setup/domain/repository/i_event_preview_repository.dart';

class RefreshEventPreviewUseCase {
  final Ref _ref;
  final IEventPreviewRepository _repository;

  RefreshEventPreviewUseCase(this._ref, this._repository);

  Future<void> execute(int machineId) async {
    final deviceUUID = await _ref.read(deviceUuidProvider.future);

    await _ref.read(kioskInfoServiceProvider.notifier).refreshWithMachineId(machineId);

    await _repository.createUniqueKeyHistory(
      UniqueKeyRequest(
        machineId: machineId.toString(),
        uniqueKey: deviceUUID,
      ),
    );

    SlackLogService().sendBroadcastLogToSlackWithKey(InfoKey.inspectionStart.key);
  }
}
