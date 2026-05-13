import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'payment_history_action.freezed.dart';

@freezed
sealed class PaymentHistoryAction with _$PaymentHistoryAction {
  const factory PaymentHistoryAction.goToPage(int page) = PaymentHistoryActionGoToPage;
  const factory PaymentHistoryAction.requestRefund(OrderEntity order) = PaymentHistoryActionRequestRefund;
  const factory PaymentHistoryAction.confirmRefund() = PaymentHistoryActionConfirmRefund;
  const factory PaymentHistoryAction.cancelRefund() = PaymentHistoryActionCancelRefund;
  const factory PaymentHistoryAction.acknowledgeResult() = PaymentHistoryActionAcknowledgeResult;
}
