import 'package:freezed_annotation/freezed_annotation.dart';

part 'payment_action.freezed.dart';

@freezed
sealed class PaymentAction with _$PaymentAction {
  const factory PaymentAction.pay() = PaymentActionPay;
  const factory PaymentAction.reset() = PaymentActionReset;
  const factory PaymentAction.selectFixed(int index) = PaymentActionSelectFixed;
  const factory PaymentAction.refreshBackPhoto() = PaymentActionRefreshBackPhoto;
}
