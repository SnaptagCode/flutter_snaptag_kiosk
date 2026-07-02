import 'package:flutter_snaptag_kiosk/core/data/models/response/kscat_device_response.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';

abstract class PaymentGateway {
  Future<PaymentResponse> approve({
    required int totalAmount,
  });

  Future<KscatDeviceResponse> check();

  Future<PaymentResponse> cancel({
    required int totalAmount,
    required String originalApprovalNo,
    required String originalApprovalDate,
  });
}

/// 결제 비활성(무료 모드) 상태에서 approve 호출 시 발생 (P1에서 사용)
class PaymentDisabledException implements Exception {
  final String message;

  const PaymentDisabledException([this.message = '결제 기능이 비활성화되어 있습니다.']);

  @override
  String toString() => message;
}
