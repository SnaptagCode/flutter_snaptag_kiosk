import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/models/payment_response.dart';

part 'payment_response_state.g.dart';

@riverpod
class PaymentResponseState extends _$PaymentResponseState {
  @override
  AsyncValue<PaymentResponse?> build() {
    return const AsyncValue.data(null);
  }

  void setResponse(PaymentResponse response) {
    state = AsyncValue.data(response);
  }

  void setError(Object error, StackTrace stackTrace) {
    state = AsyncValue.error(error, stackTrace);
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}
