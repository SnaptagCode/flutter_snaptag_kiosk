import 'package:flutter_snaptag_kiosk/presentation/setup/main/notifiers/page_print_notifier.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'setup_main_action.freezed.dart';

@freezed
sealed class SetupMainAction with _$SetupMainAction {
  // 인쇄 설정
  const factory SetupMainAction.selectPrintType(PagePrintType type) = SetupMainActionSelectPrintType;
  const factory SetupMainAction.updateCardCount(int count) = SetupMainActionUpdateCardCount;
  // 이벤트 실행 (2-step: validate → confirm)
  const factory SetupMainAction.requestEventStart() = SetupMainActionRequestEventStart;
  const factory SetupMainAction.confirmEventStart() = SetupMainActionConfirmEventStart;
  const factory SetupMainAction.cancelEventStart() = SetupMainActionCancelEventStart;
  // 앱 종료
  const factory SetupMainAction.requestExitApp() = SetupMainActionRequestExitApp;
  // 네비게이션 (Root에서 직접 처리)
  const factory SetupMainAction.requestEventPreview() = SetupMainActionRequestEventPreview;
  const factory SetupMainAction.requestPaymentHistory() = SetupMainActionRequestPaymentHistory;
  const factory SetupMainAction.requestMaintenance() = SetupMainActionRequestMaintenance;
  const factory SetupMainAction.requestKioskComponents() = SetupMainActionRequestKioskComponents;
  const factory SetupMainAction.requestUnitTest() = SetupMainActionRequestUnitTest;
  const factory SetupMainAction.requestUpdate() = SetupMainActionRequestUpdate;
}
