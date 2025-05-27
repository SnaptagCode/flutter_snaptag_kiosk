import 'package:flutter_riverpod/flutter_riverpod.dart';

class PaymentFailureNotifier extends StateNotifier<bool> {
  PaymentFailureNotifier() : super(false);

  void triggerFailure() => state = true;
  void reset() => state = false;
}

final paymentFailureProvider =
StateNotifierProvider<PaymentFailureNotifier, bool>(
      (ref) => PaymentFailureNotifier(),
);
