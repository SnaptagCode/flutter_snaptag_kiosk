import 'package:flutter_snaptag_kiosk/domain/models/payment/payment_result.dart';
import 'package:flutter_snaptag_kiosk/presentation/core/slack_log_provider.dart';
import 'package:flutter_snaptag_kiosk/presentation/payment/notifier/create_order_info_notifier.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'payment_response_notifier.g.dart';

@Riverpod(keepAlive: true)
class PaymentResponseState extends _$PaymentResponseState {
  @override
  PaymentResult? build() => null;

  void update(PaymentResult response) {
    try {
      final approvalNo = response.approvalNo ?? '';
      if (response.res != '0000' || approvalNo.trim().isEmpty) {
        final orderResponse = ref.read(createOrderInfoProvider);
        ref.read(slackLogServiceProvider).sendLog('OrderResponse : $orderResponse');
      }

      ref.read(slackLogServiceProvider).sendLog('PaymentResponse: $response');
    } catch (e) {
      ref.read(slackLogServiceProvider).sendLog('PaymentResponseState Exception: $e');
    }

    state = response;
  }

  void reset() => state = null;
}
