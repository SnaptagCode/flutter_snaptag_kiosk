import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_snaptag_kiosk/core/services/payment/kscat_payment_gateway.dart';
import 'package:flutter_snaptag_kiosk/core/services/payment/payment_gateway.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'payment_gateway_provider.g.dart';

@Riverpod(keepAlive: true)
KscatPaymentGateway kscatPaymentGateway(Ref ref) {
  return KscatPaymentGateway(
    PaymentApiClient(),
    ref,
  );
}

/// P0: 항상 KSCAT 반환. (P1: paymentModeProvider를 watch해 OFF면 DisabledPaymentGateway로 스왑)
@riverpod
PaymentGateway paymentGateway(Ref ref) {
  return ref.watch(kscatPaymentGatewayProvider);
}
