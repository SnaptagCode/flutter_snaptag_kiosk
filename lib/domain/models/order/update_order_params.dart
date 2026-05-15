import 'package:flutter_snaptag_kiosk/domain/models/enums/order_status.dart';
import 'package:flutter_snaptag_kiosk/domain/models/payment/payment_result.dart';

class UpdateOrderParams {
  final int kioskEventId;
  final int kioskMachineId;
  final int photoCardPrice;
  final String photoAuthNumber;
  final PaymentResult? approval;
  final int orderId;
  final bool isRefund;
  final String? description;

  const UpdateOrderParams({
    required this.kioskEventId,
    required this.kioskMachineId,
    required this.photoCardPrice,
    required this.photoAuthNumber,
    this.approval,
    required this.orderId,
    required this.isRefund,
    this.description,
  });
}

class UpdateHistoryOrderParams {
  final int kioskEventId;
  final int kioskMachineId;
  final String photoAuthNumber;
  final int amount;
  final OrderStatus status;
  final String approvalNumber;
  final String purchaseAuthNumber;
  final String authSeqNumber;
  final String detail;
  final String? description;

  const UpdateHistoryOrderParams({
    required this.kioskEventId,
    required this.kioskMachineId,
    required this.photoAuthNumber,
    required this.amount,
    required this.status,
    required this.approvalNumber,
    required this.purchaseAuthNumber,
    required this.authSeqNumber,
    this.detail = '{}',
    this.description,
  });

  UpdateHistoryOrderParams copyWith({
    OrderStatus? status,
    String? description,
  }) =>
      UpdateHistoryOrderParams(
        kioskEventId: kioskEventId,
        kioskMachineId: kioskMachineId,
        photoAuthNumber: photoAuthNumber,
        amount: amount,
        status: status ?? this.status,
        approvalNumber: approvalNumber,
        purchaseAuthNumber: purchaseAuthNumber,
        authSeqNumber: authSeqNumber,
        detail: detail,
        description: description ?? this.description,
      );
}
