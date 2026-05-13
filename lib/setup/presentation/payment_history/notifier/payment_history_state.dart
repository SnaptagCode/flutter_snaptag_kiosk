import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'payment_history_state.freezed.dart';

@freezed
sealed class PaymentHistoryState with _$PaymentHistoryState {
  const factory PaymentHistoryState.loading() = PaymentHistoryStateLoading;
  const factory PaymentHistoryState.loaded(OrderListResponse orders) = PaymentHistoryStateLoaded;
  const factory PaymentHistoryState.awaitingRefundConfirmation({
    required OrderListResponse orders,
    required OrderEntity pendingOrder,
  }) = PaymentHistoryStateAwaitingRefundConfirmation;
  const factory PaymentHistoryState.refundSuccess(OrderListResponse orders) = PaymentHistoryStateRefundSuccess;
  const factory PaymentHistoryState.failure({
    required PaymentHistoryFailure failure,
    OrderListResponse? orders,
  }) = PaymentHistoryStateFailure;
}

@freezed
sealed class PaymentHistoryFailure with _$PaymentHistoryFailure {
  const factory PaymentHistoryFailure.loadFailed(Object error) = PaymentHistoryFailureLoadFailed;
  const factory PaymentHistoryFailure.refundFailed(Object error) = PaymentHistoryFailureRefundFailed;
}
