import 'package:flutter_snaptag_kiosk/core/data/models/response/kscat_device_response.dart';
import 'package:flutter_snaptag_kiosk/core/services/payment/payment_gateway.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';

/// approve는 막지만, 환불 경로(원격 환불 전 check 포함)는 결제 토글과 무관하게
/// 동작해야 하므로 실제 게이트웨이로 위임한다.
class DisabledPaymentGateway implements PaymentGateway {
  DisabledPaymentGateway(this._delegate);

  final PaymentGateway _delegate;

  @override
  Future<PaymentResponse> approve({
    required int totalAmount,
  }) async {
    throw const PaymentDisabledException();
  }

  @override
  Future<KscatDeviceResponse> check() {
    return _delegate.check();
  }

  @override
  Future<PaymentResponse> cancel({
    required int totalAmount,
    required String originalApprovalNo,
    required String originalApprovalDate,
  }) {
    return _delegate.cancel(
      totalAmount: totalAmount,
      originalApprovalNo: originalApprovalNo,
      originalApprovalDate: originalApprovalDate,
    );
  }
}
