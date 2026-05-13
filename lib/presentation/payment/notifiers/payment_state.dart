import 'package:freezed_annotation/freezed_annotation.dart';

part 'payment_state.freezed.dart';

@freezed
class PaymentState with _$PaymentState {
  const factory PaymentState.initial() = PaymentStateInitial;
  const factory PaymentState.loading() = PaymentStateLoading;
  const factory PaymentState.success() = PaymentStateSuccess;
  const factory PaymentState.failure(Object error, StackTrace stackTrace) = PaymentStateFailure;
}
