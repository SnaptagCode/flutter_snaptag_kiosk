import 'package:flutter_snaptag_kiosk/lib.dart';

class CancelPaymentUseCase {
  CancelPaymentUseCase(this._repository);

  final IPaymentRepository _repository;

  Future<PaymentResponse> call({
    required int totalAmount,
    required String originalApprovalNo,
    required String originalApprovalDate,
  }) {
    return _repository.cancel(
      totalAmount: totalAmount,
      originalApprovalNo: originalApprovalNo,
      originalApprovalDate: originalApprovalDate,
    );
  }
}
