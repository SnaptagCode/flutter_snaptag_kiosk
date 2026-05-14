import 'package:flutter_snaptag_kiosk/lib.dart';

abstract interface class IPaymentRepository {
  Future<PaymentResponse> approve({required int totalAmount});

  Future<PaymentResponse> cancel({
    required int totalAmount,
    required String originalApprovalNo,
    required String originalApprovalDate,
  });

  Future<KscatDeviceResponse> check();
}
