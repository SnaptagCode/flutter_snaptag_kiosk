import 'package:flutter_snaptag_kiosk/core/common/constants/default.dart';
import 'package:flutter_snaptag_kiosk/data/datasources/hardware/payment_terminal/i_payment_terminal_datasource.dart';
import 'package:flutter_snaptag_kiosk/data/models/models.dart';
import 'package:flutter_snaptag_kiosk/domain/domain.dart';
import 'package:flutter_snaptag_kiosk/domain/models/payment/device_check_result.dart';
import 'package:flutter_snaptag_kiosk/domain/models/payment/payment_result.dart';

class PaymentRepository implements IPaymentRepository {
  PaymentRepository(this._client);

  final IPaymentTerminalDatasource _client;

  String _getCallback(int? kioskMachineId) {
    final formattedMachineId = kioskMachineId.toString().padLeft(2, '0');
    return 'jsonp200911MI$formattedMachineId';
  }

  @override
  Future<PaymentResult> approve({
    required int? kioskMachineId,
    required String? cardTerminalId,
    required int totalAmount,
  }) async {
    final Invoice invoice = Invoice.calculate(totalAmount);
    final request = PaymentRequest.approval(
      cardTerminalId: cardTerminalId ?? defaultCardTerminalId,
      totalAmount: invoice.total.toString(),
      tax: invoice.taxAmount.toString(),
      supplyAmount: invoice.supplyAmount.toString(),
    );

    return _request(request, kioskMachineId);
  }

  @override
  Future<DeviceCheckResult> check({
    required int? kioskMachineId,
    required String? cardTerminalId,
  }) async {
    final request = KscatDeviceRequest(req: 'C0');
    return _deviceRequest(request, kioskMachineId);
  }

  @override
  Future<PaymentResult> cancel({
    required int? kioskMachineId,
    required String? cardTerminalId,
    required int totalAmount,
    required String originalApprovalNo,
    required String originalApprovalDate,
  }) async {
    final Invoice invoice = Invoice.calculate(totalAmount);
    final request = PaymentRequest.cancel(
      totalAmount: invoice.total.toString(),
      tax: invoice.taxAmount.toString(),
      supplyAmount: invoice.supplyAmount.toString(),
      originalApprovalNo: originalApprovalNo,
      originalApprovalDate: originalApprovalDate,
      cardTerminalId: cardTerminalId ?? defaultCardTerminalId,
    );

    return _request(request, kioskMachineId);
  }

  Future<PaymentResult> _request(PaymentRequest request, int? kioskMachineId) async {
    try {
      final response = await _client.requestPayment(
        _getCallback(kioskMachineId),
        request.serialize(),
      );
      return response.toDomain();
    } catch (e) {
      rethrow;
    }
  }

  Future<DeviceCheckResult> _deviceRequest(KscatDeviceRequest request, int? kioskMachineId) async {
    try {
      final response = await _client.requestDevice(
        _getCallback(kioskMachineId),
        request.serialize(),
      );
      return response.toDomain();
    } catch (e) {
      rethrow;
    }
  }
}
