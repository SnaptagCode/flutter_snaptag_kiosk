import 'package:flutter_snaptag_kiosk/domain/models/payment/payment_result.dart';
import 'package:flutter_snaptag_kiosk/domain/repositories/i_payment_repository.dart';

class ApprovePaymentUseCase {
  ApprovePaymentUseCase(
    this._repository, {
    required int? kioskMachineId,
    required String? cardTerminalId,
  })  : _kioskMachineId = kioskMachineId,
        _cardTerminalId = cardTerminalId;

  final IPaymentRepository _repository;
  final int? _kioskMachineId;
  final String? _cardTerminalId;

  Future<PaymentResult> call({required int totalAmount}) {
    return _repository.approve(
      kioskMachineId: _kioskMachineId,
      cardTerminalId: _cardTerminalId,
      totalAmount: totalAmount,
    );
  }
}
