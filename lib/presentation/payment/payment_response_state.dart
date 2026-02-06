import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:flutter_snaptag_kiosk/presentation/payment/create_order_info_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'payment_response_state.g.dart';

@Riverpod(keepAlive: true)
class PaymentResponseState extends _$PaymentResponseState {
  @override
  PaymentResponse? build() => null;

  void update(PaymentResponse response) {
    try {
      final approvalNo = response.approvalNo ?? '';
      if (response.res != '0000' || approvalNo.trim().isEmpty) {
        final orderResponse = ref.read(createOrderInfoProvider);
        SlackLogService().sendLogToSlack('OrderResponse : $orderResponse');
      }

      SlackLogService().sendLogToSlack('PaymentResponse: $response');
    } catch (e) {
      SlackLogService().sendLogToSlack('PaymentResponseState Exception: $e');
    }

    state = response;
  }

  void reset() => state = null;
}
