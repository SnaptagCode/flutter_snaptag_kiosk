import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_snaptag_kiosk/data/datasources/remote/slack_log_service.dart';
import 'package:flutter_snaptag_kiosk/presentation/core/card_count_provider.dart';
import 'package:flutter_snaptag_kiosk/presentation/kiosk_shell/kiosk_info_service.dart';
import 'package:flutter_snaptag_kiosk/presentation/setup/di/setup_di.dart';

class EndKioskApplicationUseCase {
  final Ref _ref;

  EndKioskApplicationUseCase(this._ref);

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
      SlackLogService().sendErrorLogToSlack('End Kiosk Application: $e');
    }
  }
}
