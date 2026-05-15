import 'package:flutter_snaptag_kiosk/domain/models/payment/device_check_result.dart';
import 'package:flutter_snaptag_kiosk/domain/models/payment/payment_result.dart';

abstract interface class IPaymentRepository {
  Future<PaymentResult> approve({
    required int? kioskMachineId,
    required String? cardTerminalId,
    required int totalAmount,
  });

  Future<PaymentResult> cancel({
    required int? kioskMachineId,
    required String? cardTerminalId,
    required int totalAmount,
    required String originalApprovalNo,
    required String originalApprovalDate,
  });

  Future<DeviceCheckResult> check({
    required int? kioskMachineId,
    required String? cardTerminalId,
  });
}
