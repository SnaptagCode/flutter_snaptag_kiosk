import 'package:flutter_snaptag_kiosk/core/common/constants/alert_key.dart';
import 'package:flutter_snaptag_kiosk/domain/repositories/i_setup_repository.dart';
import 'package:flutter_snaptag_kiosk/domain/services/i_id_writer_service.dart';
import 'package:flutter_snaptag_kiosk/domain/services/i_slack_log_service.dart';
import 'package:flutter_snaptag_kiosk/domain/usecases/payment/check_payment_device_use_case.dart';
import 'package:flutter_snaptag_kiosk/presentation/setup/main/notifiers/page_print_notifier.dart'; // TODO: PagePrintType → domain/models 이동 후 경로 업데이트

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
  final ISetupRepository _setupRepository;
  final CheckPaymentDeviceUseCase _checkPaymentDevice;
  final ISlackLogService _slackLog;
  final IIdWriterService _idWriter;

  StartKioskEventUseCase(
    this._setupRepository,
    this._checkPaymentDevice,
    this._slackLog,
    this._idWriter,
  );

  Future<StartEventValidationResult> validate({
    required PagePrintType printType,
    required int? kioskEventId,
    required int? kioskMachineId,
  }) async {
    if (printType == PagePrintType.none) {
      return const StartEventValidationPrintTypeNotSelected();
    }

    // TODO: 프린터 없이 디버깅 시 주석 해제
    // final connected = await _printerService.connectedPrinter();
    // if (!connected) return const StartEventValidationPrinterNotConnected();

    // final settingOk = await _printerService.checkSettingPrinter();
    // if (!settingOk) return const StartEventValidationPrinterNotReady();

    try {
      final response = await _checkPaymentDevice.call();
      _slackLog.sendLog('Payment Device check: $response');
    } catch (e) {
      _slackLog.sendErrorLog('Payment Device check: $e');
      return const StartEventValidationPaymentDeviceNotReady();
    }

    if (kioskEventId == null || kioskMachineId == null || kioskEventId == 0 || kioskMachineId == 0) {
      return const StartEventValidationKioskInfoInvalid();
    }

    return const StartEventValidationOk();
  }

  Future<void> execute({
    required int machineId,
    required int kioskEventId,
    required String remainingSingleSidedCount,
    required int cardInitialCount,
    required int cardCurrentCount,
    required String currentVersion,
    required String latestVersion,
    required String? eventType,
  }) async {
    await _writePhotocodeMeta(
      machineId: machineId,
      kioskEventId: kioskEventId,
      cardInitialCount: cardInitialCount,
      cardCurrentCount: cardCurrentCount,
      currentVersion: currentVersion,
      eventType: eventType,
    );

    try {
      await _setupRepository.deleteEndMark(
        kioskEventId: kioskEventId,
        machineId: machineId,
        remainingSingleSidedCount: remainingSingleSidedCount,
      );
    } catch (e) {
      _slackLog.sendErrorLog('Delete End Mark: $e');
    }

    _slackLog.sendLog(
      'machineId:$machineId, currentVersion:$currentVersion, latestVersion:$latestVersion',
    );
    _slackLog.sendInspectionEndBroadcastLog(InfoKey.inspectionEnd.key);
  }

  Future<void> _writePhotocodeMeta({
    required int machineId,
    required int kioskEventId,
    required int cardInitialCount,
    required int cardCurrentCount,
    required String currentVersion,
    required String? eventType,
  }) async {
    const serviceNameMap = {
      'SUF': '수원FC',
      'SEF': '서울 이랜드 FC',
      'KEEFO': '성수 B\'Day',
      'AGFC': '안산그리너스FC',
    };
    final serviceName = serviceNameMap[eventType] ?? '-';
    final cardCountInfo = '$cardInitialCount / $cardCurrentCount';

    await _idWriter.writePhotocodeMeta(
      machineId: machineId.toString(),
      kioskEventId: kioskEventId.toString(),
      cardCountInfo: cardCountInfo,
      serviceName: serviceName,
      version: currentVersion,
    );
  }
}
