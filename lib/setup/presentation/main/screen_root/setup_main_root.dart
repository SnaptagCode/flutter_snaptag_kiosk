import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_snaptag_kiosk/core/common/constants/alert_key.dart';
import 'package:flutter_snaptag_kiosk/core/common/launcher/launcher_service.dart';
import 'package:flutter_snaptag_kiosk/data/datasources/local/id_writer.dart';
import 'package:flutter_snaptag_kiosk/data/datasources/remote/slack_log_service.dart';
import 'package:flutter_snaptag_kiosk/core/providers/version_notifier.dart';
import 'package:flutter_snaptag_kiosk/core/ui/widget/dialog_helper.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:flutter_snaptag_kiosk/presentation/core/card_count_provider.dart';
import 'package:flutter_snaptag_kiosk/presentation/kiosk_shell/kiosk_info_service.dart';
import 'package:flutter_snaptag_kiosk/presentation/print/luca/state/printer_connect_state.dart';
import 'package:flutter_snaptag_kiosk/presentation/setup/main/notifiers/page_print_notifier.dart';
import 'package:flutter_snaptag_kiosk/setup/presentation/main/notifier/setup_main_action.dart';
import 'package:flutter_snaptag_kiosk/setup/presentation/main/notifier/setup_main_notifier.dart';
import 'package:flutter_snaptag_kiosk/setup/presentation/main/notifier/setup_main_state.dart';
import 'package:flutter_snaptag_kiosk/setup/presentation/main/screen/setup_main_screen.dart';
import 'package:flutter_snaptag_kiosk/setup/presentation/main/screen/setup_main_screen_state.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loader_overlay/loader_overlay.dart';

class SetupMainRoot extends ConsumerStatefulWidget {
  const SetupMainRoot({super.key});

  @override
  ConsumerState<SetupMainRoot> createState() => _SetupMainRootState();
}

class _SetupMainRootState extends ConsumerState<SetupMainRoot> {
  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(setupMainNotifierProvider.notifier);
    final versionState = ref.watch(versionNotifierProvider);

    final screenState = SetupMainScreenState(
      pagePrintType: ref.watch(pagePrintProvider),
      cardCount: ref.watch(cardCountProvider).currentCount,
      currentVersion: versionState.currentVersion,
      latestVersion: versionState.latestVersion,
      isPrinterConnected: ref.watch(printerConnectProvider) == PrinterConnectState.connected,
      hasKioskInfo: ref.watch(kioskInfoServiceProvider.notifier).getInfoByKey,
    );

    ref.listen<SetupMainState>(setupMainNotifierProvider, (_, state) async {
      switch (state) {
        case SetupMainStateLoading():
          if (!context.loaderOverlay.visible) context.loaderOverlay.show();
        case SetupMainStateAwaitingEventConfirmation():
          if (context.loaderOverlay.visible) context.loaderOverlay.hide();
          if (!context.mounted) return;
          final confirmed = await DialogHelper.showSetupDialog(
            context,
            title: '이벤트를 실행합니다.',
            showCancelButton: true,
          );
          if (!context.mounted) return;
          notifier.onAction(
            confirmed
                ? const SetupMainAction.confirmEventStart()
                : const SetupMainAction.cancelEventStart(),
          );
        case SetupMainStateEventStartSuccess():
          if (context.loaderOverlay.visible) context.loaderOverlay.hide();
          if (context.mounted) HomeRouteData().go(context);
        case SetupMainStateExitAppSuccess():
          exit(0);
        case SetupMainStateFailure(:final failure):
          if (context.loaderOverlay.visible) context.loaderOverlay.hide();
          if (!context.mounted) return;
          await _showFailureDialog(context, failure);
          if (context.mounted) notifier.onAction(const SetupMainAction.cancelEventStart());
        case SetupMainStateInitial():
          if (context.loaderOverlay.visible) context.loaderOverlay.hide();
      }
    });

    return LoaderOverlay(
      overlayWidgetBuilder: (_) => Center(
        child: SizedBox(
          width: 350.h,
          height: 350.h,
          child: CircularProgressIndicator(strokeWidth: 15.h),
        ),
      ),
      child: SetupMainScreen(
      state: screenState,
      onAction: (action) async {
        switch (action) {
          case SetupMainActionRequestEventPreview():
            if (ref.read(cardCountProvider).currentCount < 1) {
              ref.read(pagePrintProvider.notifier).set(PagePrintType.double);
            }
            EventPreviewRouteData().go(context);
          case SetupMainActionRequestPaymentHistory():
            PaymentHistoryRouteData().go(context);
          case SetupMainActionRequestMaintenance():
            SlackLogService().sendBroadcastLogToSlackWithKey(InfoKey.serviceMaintenanceEnter.key);
            MaintenanceRouteData().go(context);
          case SetupMainActionRequestKioskComponents():
            KioskComponentsRouteData().go(context);
          case SetupMainActionRequestUnitTest():
            UnitTestRouteData().go(context);
          case SetupMainActionRequestUpdate():
            await _handleUpdate(context);
          default:
            notifier.onAction(action);
        }
      },
    ),
    );
  }

  Future<void> _showFailureDialog(BuildContext context, SetupMainFailure failure) async {
    switch (failure) {
      case SetupMainFailurePrintTypeNotSelected():
        await DialogHelper.showSetupDialog(context, title: '인쇄 타입을 선택해주세요.');
      case SetupMainFailurePrinterNotConnected():
        await DialogHelper.showSetupDialog(context, title: '프린트가 준비중입니다.');
      case SetupMainFailurePrinterNotReady():
        await DialogHelper.showSetupDialog(context, title: '프린트 기기 상태를 확인해주세요.');
      case SetupMainFailurePaymentDeviceNotReady():
        await DialogHelper.showSetupDialog(
          context,
          title: '리더기 점검',
          content: '리더기 응답이 없습니다.\n연결 상태를 확인한 뒤 다시 시도해 주세요.',
        );
      case SetupMainFailureKioskInfoInvalid():
        await DialogHelper.showSetupDialog(context, title: '이벤트를 실행하려면\n키오스크 기기번호를 입력해 주세요.');
      case SetupMainFailureEventStartFailed(:final error):
        SlackLogService().sendErrorLogToSlack('Event Start Failed: $error');
        await DialogHelper.showSetupDialog(context, title: '이벤트 실행 중 오류가 발생했습니다.');
    }
  }

  Future<void> _handleUpdate(BuildContext context) async {
    final result = await DialogHelper.showKioskDialog(
      context,
      title: '업데이트 하시겠습니까?',
      contentText: '업데이트 시 앱이 재시작 됩니다.',
      cancelButtonText: '취소',
      confirmButtonText: '완료',
    );
    if (!result) return;
    try {
      final launcherPath = await LauncherPathUtil.getLauncherPath();
      await ForceUpdateWriter.writeForceUpdateTrue();
      await Process.start(launcherPath, ['f'], runInShell: true, mode: ProcessStartMode.detached);
      exit(0);
    } catch (e) {
      logger.e('런처 실행 실패: $e');
    }
  }
}
