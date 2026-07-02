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

/// 결제 모드에 따라 게이트웨이를 교체하는 지점. 현재는 항상 KSCAT를 반환한다.
@riverpod
PaymentGateway paymentGateway(Ref ref) {
  return ref.watch(kscatPaymentGatewayProvider);
}
