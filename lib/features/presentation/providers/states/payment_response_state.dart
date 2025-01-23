import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'payment_response_state.g.dart';

@Riverpod(keepAlive: true)
class PaymentResponseState extends _$PaymentResponseState {
  @override
  PaymentResponse? build() => null;

  void update(PaymentResponse response) => state = response;
  void reset() => state = null;
}
