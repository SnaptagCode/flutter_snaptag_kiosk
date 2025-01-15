import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'payment_repository.g.dart';

@riverpod
PaymentRepository paymentRepository(Ref ref) {
  return PaymentRepository(
    PaymentApiClient(),
    ref,
  );
}

class PaymentRepository {
  PaymentRepository(this._client, this.ref);

  final PaymentApiClient _client;
  final Ref ref;

  String _getCallback() {
    final kioskMachineId = ref.read(storageServiceProvider).settings.kioskMachineId;
    final formattedMachineId = kioskMachineId.toString().padLeft(2, '0');
    return 'jsonp200911MI$formattedMachineId';
  }

  Future<PaymentResponse> approve({
    required String totalAmount,
    required String tax,
    required String supplyAmount,
  }) async {
    final request = PaymentRequest.approval(
      totalAmount: totalAmount,
      tax: tax,
      supplyAmount: supplyAmount,
      isTest: true,
    );

    return _request(request);
  }

  Future<PaymentResponse> cancel({
    required String totalAmount,
    required String tax,
    required String supplyAmount,
    required String originalApprovalNo,
    required String originalApprovalDate,
  }) async {
    final request = PaymentRequest.cancel(
      totalAmount: totalAmount,
      tax: tax,
      supplyAmount: supplyAmount,
      originalApprovalNo: originalApprovalNo,
      originalApprovalDate: originalApprovalDate,
      isTest: true,
    );

    return _request(request);
  }

  Future<PaymentResponse> _request(PaymentRequest request) async {
    try {
      final response = await _client.requestPayment(
        _getCallback(),
        request.serialize(),
      );

      if (response.res == '0100') {
        throw const PaymentException.needRecheck();
      } else if (response.res == '0800') {
        throw const PaymentException.inProgress();
      } else if (response.res != '0000') {
        throw PaymentException.error(response.msg ?? 'Unknown error');
      }

      return response;
    } on http.ClientException catch (e, s) {
      throw PaymentClientException('Network error: $e', s);
    }
  }
}
