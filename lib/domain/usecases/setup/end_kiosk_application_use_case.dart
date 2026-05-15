import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_snaptag_kiosk/domain/services/i_slack_log_service.dart';
import 'package:flutter_snaptag_kiosk/presentation/core/card_count_provider.dart';
import 'package:flutter_snaptag_kiosk/presentation/kiosk_shell/kiosk_info_service.dart';
import 'package:flutter_snaptag_kiosk/presentation/setup/di/setup_di.dart';

class EndKioskApplicationUseCase {
  final Ref _ref;
  final ISlackLogService _slackLog;

  EndKioskApplicationUseCase(this._ref, this._slackLog);

  Future<void> call() async {
    final kioskInfo = _ref.read(kioskInfoServiceProvider);
    final cardCountState = _ref.read(cardCountProvider);

    try {
      await _ref.read(setupRepositoryProvider).endKioskApplication(
            kioskEventId: kioskInfo?.kioskEventId ?? 0,
            machineId: kioskInfo?.kioskMachineId ?? 0,
            remainingSingleSidedCount: cardCountState.remainingSingleSidedCount,
          );
    } catch (e) {
      _slackLog.sendErrorLog('End Kiosk Application: $e');
    }
  }
}
