import 'package:flutter_snaptag_kiosk/domain/models/enums/order_status.dart';
import 'package:flutter_snaptag_kiosk/domain/models/enums/printed_status.dart';

class OrderData {
  final int orderId;
  final int kioskMachineId;
  final String eventName;
  final String photoAuthNumber;
  final String? paymentAuthNumber;
  final double amount;
  final DateTime? completedAt;
  final DateTime? refundedAt;
  final OrderStatus orderStatus;
  final PrintedStatus? printedStatus;

  const OrderData({
    required this.orderId,
    required this.kioskMachineId,
    required this.eventName,
    required this.photoAuthNumber,
    required this.paymentAuthNumber,
    required this.amount,
    required this.completedAt,
    required this.refundedAt,
    required this.orderStatus,
    required this.printedStatus,
  });
}
