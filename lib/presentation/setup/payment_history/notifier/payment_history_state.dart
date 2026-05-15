import 'package:flutter_snaptag_kiosk/domain/models/order/order_data.dart';
import 'package:flutter_snaptag_kiosk/domain/models/order/order_list_result.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'payment_history_state.freezed.dart';

@freezed
sealed class PaymentHistoryState with _$PaymentHistoryState {
  const factory PaymentHistoryState.loading() = PaymentHistoryStateLoading;
  const factory PaymentHistoryState.loaded(OrderListResult orders) = PaymentHistoryStateLoaded;
  const factory PaymentHistoryState.awaitingRefundConfirmation({
    required OrderListResult orders,
    required OrderData pendingOrder,
  }) = PaymentHistoryStateAwaitingRefundConfirmation;
  const factory PaymentHistoryState.refundSuccess(OrderListResult orders) = PaymentHistoryStateRefundSuccess;
  const factory PaymentHistoryState.failure({
    required PaymentHistoryFailure failure,
    OrderListResult? orders,
  }) = PaymentHistoryStateFailure;
}

@freezed
sealed class PaymentHistoryFailure with _$PaymentHistoryFailure {
  const factory PaymentHistoryFailure.loadFailed(Object error) = PaymentHistoryFailureLoadFailed;
  const factory PaymentHistoryFailure.refundFailed(Object error) = PaymentHistoryFailureRefundFailed;
}
