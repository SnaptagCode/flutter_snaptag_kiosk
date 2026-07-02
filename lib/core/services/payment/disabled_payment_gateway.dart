import 'package:flutter_snaptag_kiosk/core/data/models/response/kscat_device_response.dart';
import 'package:flutter_snaptag_kiosk/core/services/payment/kscat_payment_gateway.dart';
import 'package:flutter_snaptag_kiosk/core/services/payment/payment_gateway.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';

/// 결제 OFF(무료 모드) 상태의 게이트웨이 — P1에서 paymentMode에 따라 스왑된다.
/// - approve: 무료 플로우는 승인을 호출하지 않으므로 방어선으로 예외
/// - check/cancel: 환불 경로(원격 환불 전 단말 확인 포함)는 토글과 무관하게
///   실제 단말로 동작해야 하므로 KSCAT에 위임
class DisabledPaymentGateway implements PaymentGateway {
  DisabledPaymentGateway(this._delegate);

  final KscatPaymentGateway _delegate;

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
