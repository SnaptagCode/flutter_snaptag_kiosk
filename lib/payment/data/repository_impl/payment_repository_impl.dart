import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_snaptag_kiosk/core/common/constants/default.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:flutter_snaptag_kiosk/presentation/kiosk_shell/kiosk_info_service.dart';

class PaymentRepository implements IPaymentRepository {
  PaymentRepository(this._client, this.ref);

  final IPaymentDatasource _client;
  final Ref ref;

  String _getCallback() {
    final kioskMachineId = ref.read(kioskInfoServiceProvider)?.kioskMachineId;
    final formattedMachineId = kioskMachineId.toString().padLeft(2, '0');
    return 'jsonp200911MI$formattedMachineId';
  }

  @override
  Future<PaymentResponse> approve({
    required int totalAmount,
  }) async {
    final Invoice invoice = Invoice.calculate(totalAmount);
    final cardTerminalId = ref.read(kioskInfoServiceProvider)?.cardTerminalId;
    final request = PaymentRequest.approval(
      cardTerminalId: cardTerminalId ?? defaultCardTerminalId,
      totalAmount: invoice.total.toString(),
      tax: invoice.taxAmount.toString(),
      supplyAmount: invoice.supplyAmount.toString(),
    );

    return _request(request);
  }

  @override
  Future<KscatDeviceResponse> check() async {
    final request = KscatDeviceRequest(req: 'C0');
    return _deviceRequest(request);
  }

  @override
  Future<PaymentResponse> cancel({
    required int totalAmount,
    required String originalApprovalNo,
    required String originalApprovalDate,
  }) async {
    final Invoice invoice = Invoice.calculate(totalAmount);
    final cardTerminalId = ref.read(kioskInfoServiceProvider)?.cardTerminalId;
    final request = PaymentRequest.cancel(
      totalAmount: invoice.total.toString(),
      tax: invoice.taxAmount.toString(),
      supplyAmount: invoice.supplyAmount.toString(),
      originalApprovalNo: originalApprovalNo,
      originalApprovalDate: originalApprovalDate,
      cardTerminalId: cardTerminalId ?? defaultCardTerminalId,
    );

    return _request(request);
  }

  Future<PaymentResponse> _request(PaymentRequest request) async {
    try {
      return await _client.requestPayment(
        _getCallback(),
        request.serialize(),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<KscatDeviceResponse> _deviceRequest(KscatDeviceRequest request) async {
    try {
      return await _client.requestDevice(
        _getCallback(),
        request.serialize(),
      );
    } catch (e) {
      rethrow;
    }
  }
}
