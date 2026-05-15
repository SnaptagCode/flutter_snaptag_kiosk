import 'dart:async';

import 'package:flutter_snaptag_kiosk/core/common/constants/alert_key.dart';
import 'package:flutter_snaptag_kiosk/core/providers/version_notifier.dart';
import 'package:flutter_snaptag_kiosk/data/datasources/remote/slack_log_service.dart';
import 'package:flutter_snaptag_kiosk/presentation/core/card_count_provider.dart';
import 'package:flutter_snaptag_kiosk/presentation/kiosk_shell/kiosk_info_service.dart';
import 'package:flutter_snaptag_kiosk/presentation/print/card_printer.dart';
import 'package:flutter_snaptag_kiosk/presentation/print/luca/state/printer_connect_state.dart';
import 'package:flutter_snaptag_kiosk/presentation/setup/main/notifiers/page_print_notifier.dart';
import 'package:flutter_snaptag_kiosk/domain/usecases/setup/end_kiosk_application_use_case.dart';
import 'package:flutter_snaptag_kiosk/domain/usecases/setup/start_kiosk_event_use_case.dart';
import 'package:flutter_snaptag_kiosk/presentation/setup/di/setup_di.dart';
import 'package:flutter_snaptag_kiosk/presentation/setup/main/notifier/setup_main_action.dart';
import 'package:flutter_snaptag_kiosk/presentation/setup/main/notifier/setup_main_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'setup_main_notifier.g.dart';

@riverpod
class SetupMainNotifier extends _$SetupMainNotifier {
  late final StartKioskEventUseCase _startKioskEventUseCase;
  late final EndKioskApplicationUseCase _endKioskApplicationUseCase;

  @override
  SetupMainState build() {
    _startKioskEventUseCase = ref.watch(startKioskEventUseCaseProvider);
    _endKioskApplicationUseCase = ref.watch(endKioskApplicationUseCaseProvider);

    final timer = Timer.periodic(const Duration(seconds: 2), (_) => _pollPrinterStatus());
    ref.onDispose(timer.cancel);

    return const SetupMainState.initial();
  }

  Future<void> _pollPrinterStatus() async {
    final connected = await ref.read(printerServiceProvider.notifier).connectedPrinter();
    final newState = connected
        ? (await ref.read(printerServiceProvider.notifier).checkSettingPrinter()
            ? PrinterConnectState.connected
            : PrinterConnectState.setupInComplete)
        : PrinterConnectState.disconnected;
    ref.read(printerConnectProvider.notifier).update(newState);
  }

  Future<void> onAction(SetupMainAction action) async {
    switch (action) {
      case SetupMainActionSelectPrintType(:final type):
        ref.read(pagePrintProvider.notifier).set(type);

      case SetupMainActionUpdateCardCount(:final count):
        ref.read(cardCountProvider.notifier).update(count);
        if (count <= 0) {
          ref.read(pagePrintProvider.notifier).set(PagePrintType.double);
        } else {
          ref.read(pagePrintProvider.notifier).set(PagePrintType.single);
          final machineId = ref.read(kioskInfoServiceProvider)?.kioskMachineId ?? 0;
          if (machineId != 0) {
            SlackLogService().sendBroadcastLogToSlackWithKey(InfoKey.cardPrintModeSwitchSingle.key);
          }
        }

      case SetupMainActionRequestEventStart():
        await _validateAndAwaitConfirmation();

      case SetupMainActionConfirmEventStart():
        await _executeEventStart();

      case SetupMainActionCancelEventStart():
        state = const SetupMainState.initial();

      case SetupMainActionRequestExitApp():
        await _handleExitApp();

      default:
        break;
    }
  }

  Future<void> _validateAndAwaitConfirmation() async {
    state = const SetupMainState.loading();

    // 단면+수량0 → 양면으로 자동 전환
    if (ref.read(pagePrintProvider) == PagePrintType.single &&
        ref.read(cardCountProvider).currentCount == 0) {
      ref.read(pagePrintProvider.notifier).set(PagePrintType.double);
    }

    // kioskInfo가 없으면 먼저 로드
    var kioskInfo = ref.read(kioskInfoServiceProvider);
    if (kioskInfo == null) {
      await ref.read(kioskInfoServiceProvider.notifier).getKioskMachineInfo();
      kioskInfo = ref.read(kioskInfoServiceProvider);
    }

    final result = await _startKioskEventUseCase.validate(
      printType: ref.read(pagePrintProvider),
      kioskEventId: kioskInfo?.kioskEventId,
      kioskMachineId: kioskInfo?.kioskMachineId,
    );

    state = switch (result) {
      StartEventValidationOk() => const SetupMainState.awaitingEventConfirmation(),
      StartEventValidationPrintTypeNotSelected() =>
        const SetupMainState.failure(SetupMainFailure.printTypeNotSelected()),
      StartEventValidationPrinterNotConnected() =>
        const SetupMainState.failure(SetupMainFailure.printerNotConnected()),
      StartEventValidationPrinterNotReady() =>
        const SetupMainState.failure(SetupMainFailure.printerNotReady()),
      StartEventValidationPaymentDeviceNotReady() =>
        const SetupMainState.failure(SetupMainFailure.paymentDeviceNotReady()),
      StartEventValidationKioskInfoInvalid() =>
        const SetupMainState.failure(SetupMainFailure.kioskInfoInvalid()),
    };
  }

  Future<void> _executeEventStart() async {
    state = const SetupMainState.loading();

    try {
      final kioskInfo = ref.read(kioskInfoServiceProvider);
      final cardCountState = ref.read(cardCountProvider);
      final versionState = ref.read(versionNotifierProvider);

      try {
        await ref.read(printerServiceProvider.notifier).printerStateLog();
      } catch (_) {}

      await _startKioskEventUseCase.execute(
        machineId: kioskInfo?.kioskMachineId ?? 0,
        kioskEventId: kioskInfo?.kioskEventId ?? 0,
        remainingSingleSidedCount: cardCountState.remainingSingleSidedCount,
        cardInitialCount: cardCountState.initialCount,
        cardCurrentCount: cardCountState.currentCount,
        currentVersion: versionState.currentVersion,
        latestVersion: versionState.latestVersion,
        eventType: kioskInfo?.eventType,
      );
      state = const SetupMainState.eventStartSuccess();
    } catch (e) {
      state = SetupMainState.failure(SetupMainFailure.eventStartFailed(e));
    }
  }

  Future<void> _handleExitApp() async {
    final kioskInfo = ref.read(kioskInfoServiceProvider);
    final cardCountState = ref.read(cardCountProvider);
    await _endKioskApplicationUseCase.call(
      kioskEventId: kioskInfo?.kioskEventId ?? 0,
      kioskMachineId: kioskInfo?.kioskMachineId ?? 0,
      remainingSingleSidedCount: cardCountState.remainingSingleSidedCount,
    );
    state = const SetupMainState.exitAppSuccess();
  }
}
