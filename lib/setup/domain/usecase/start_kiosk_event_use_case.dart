import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_snaptag_kiosk/core/common/constants/alert_key.dart';
import 'package:flutter_snaptag_kiosk/core/data/datasources/local/id_writer.dart';
import 'package:flutter_snaptag_kiosk/core/data/datasources/remote/slack_log_service.dart';
import 'package:flutter_snaptag_kiosk/payment/data/repository_impl/payment_repository_impl.dart';
import 'package:flutter_snaptag_kiosk/core/providers/version_notifier.dart';
import 'package:flutter_snaptag_kiosk/presentation/core/card_count_provider.dart';
import 'package:flutter_snaptag_kiosk/presentation/kiosk_shell/kiosk_info_service.dart';
import 'package:flutter_snaptag_kiosk/presentation/print/card_printer.dart';
import 'package:flutter_snaptag_kiosk/presentation/setup/main/notifiers/page_print_notifier.dart';
import 'package:flutter_snaptag_kiosk/setup/module/setup_di.dart';

sealed class StartEventValidationResult {
  const StartEventValidationResult();
}

final class StartEventValidationOk extends StartEventValidationResult {
  const StartEventValidationOk();
}

final class StartEventValidationPrintTypeNotSelected extends StartEventValidationResult {
  const StartEventValidationPrintTypeNotSelected();
}

final class StartEventValidationPrinterNotConnected extends StartEventValidationResult {
  const StartEventValidationPrinterNotConnected();
}

final class StartEventValidationPrinterNotReady extends StartEventValidationResult {
  const StartEventValidationPrinterNotReady();
}

final class StartEventValidationPaymentDeviceNotReady extends StartEventValidationResult {
  const StartEventValidationPaymentDeviceNotReady();
}

final class StartEventValidationKioskInfoInvalid extends StartEventValidationResult {
  const StartEventValidationKioskInfoInvalid();
}

class StartKioskEventUseCase {
  final Ref _ref;

  StartKioskEventUseCase(this._ref);

  Future<StartEventValidationResult> validate() async {
    final printType = _ref.read(pagePrintProvider);

    if (printType == PagePrintType.none) {
      return const StartEventValidationPrintTypeNotSelected();
    }

    // 단면+수량0 → 양면으로 자동 전환
    if (printType == PagePrintType.single && _ref.read(cardCountProvider).currentCount == 0) {
      _ref.read(pagePrintProvider.notifier).set(PagePrintType.double);
    }

    // TODO: 프린터 없이 디버깅 시 주석 해제
    // final connected = await _ref.read(printerServiceProvider.notifier).connectedPrinter();
    // if (!connected) return const StartEventValidationPrinterNotConnected();

    // final settingOk = await _ref.read(printerServiceProvider.notifier).checkSettingPrinter();
    // if (!settingOk) return const StartEventValidationPrinterNotReady();

    try {
      final response = await _ref.read(paymentRepositoryProvider).check();
      SlackLogService().sendLogToSlack('Payment Device check: $response');
    } catch (e) {
      SlackLogService().sendErrorLogToSlack('Payment Device check: $e');
      return const StartEventValidationPaymentDeviceNotReady();
    }

    var kioskInfo = _ref.read(kioskInfoServiceProvider);
    if (kioskInfo == null) {
      await _ref.read(kioskInfoServiceProvider.notifier).getKioskMachineInfo();
      kioskInfo = _ref.read(kioskInfoServiceProvider);
    }

    if (kioskInfo == null || kioskInfo.kioskEventId == 0 || kioskInfo.kioskMachineId == 0) {
      return const StartEventValidationKioskInfoInvalid();
    }

    return const StartEventValidationOk();
  }

  Future<void> execute() async {
    final kioskInfo = _ref.read(kioskInfoServiceProvider);
    final machineId = kioskInfo?.kioskMachineId ?? 0;
    final kioskEventId = kioskInfo?.kioskEventId ?? 0;
    final cardCountState = _ref.read(cardCountProvider);
    final versionState = _ref.read(versionNotifierProvider);

    await _writePhotocodeMeta(machineId, kioskEventId, cardCountState, versionState.currentVersion);

    try {
      await _ref.read(printerServiceProvider.notifier).printerStateLog();
    } catch (e) {
      SlackLogService().sendErrorLogToSlack('Printer State Log: $e');
    }

    try {
      await _ref.read(setupRepositoryProvider).deleteEndMark(
            kioskEventId: kioskEventId,
            machineId: machineId,
            remainingSingleSidedCount: cardCountState.remainingSingleSidedCount,
          );
    } catch (e) {
      SlackLogService().sendErrorLogToSlack('Delete End Mark: $e');
    }

    SlackLogService().sendLogToSlack(
      'machineId:$machineId, currentVersion:${versionState.currentVersion}, latestVersion:${versionState.latestVersion}',
    );
    SlackLogService().sendInspectionEndBroadcastLogToSlack(InfoKey.inspectionEnd.key);
  }

  Future<void> _writePhotocodeMeta(
    int machineId,
    int kioskEventId,
    CardCountState cardCountState,
    String currentVersion,
  ) async {
    final kioskInfo = _ref.read(kioskInfoServiceProvider);
    const serviceNameMap = {
      'SUF': '수원FC',
      'SEF': '서울 이랜드 FC',
      'KEEFO': '성수 B\'Day',
      'AGFC': '안산그리너스FC',
    };
    final eventType = kioskInfo?.eventType ?? '-';
    final serviceName = serviceNameMap[eventType] ?? '-';
    final cardCountInfo = '${cardCountState.initialCount} / ${cardCountState.currentCount}';

    await writePhotocodeId(
      machineId.toString(),
      kioskEventId.toString(),
      cardCountInfo,
      serviceName,
      currentVersion,
    );
  }
}
