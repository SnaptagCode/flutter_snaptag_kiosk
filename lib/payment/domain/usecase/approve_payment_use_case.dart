import 'package:flutter_snaptag_kiosk/lib.dart';

class ApprovePaymentUseCase {
  ApprovePaymentUseCase(this._repository);

  final IPaymentRepository _repository;

  Future<PaymentResponse> call({required int totalAmount}) {
    return _repository.approve(totalAmount: totalAmount);
  }
}
