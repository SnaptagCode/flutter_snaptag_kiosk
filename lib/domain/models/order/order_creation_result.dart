import 'package:flutter_snaptag_kiosk/domain/models/enums/order_status.dart';

class OrderCreationResult {
  final int orderId;
  final int kioskEventId;
  final int kioskMachineId;
  final int backPhotoCardId;
  final int amount;
  final OrderStatus status;

  const OrderCreationResult({
    required this.orderId,
    required this.kioskEventId,
    required this.kioskMachineId,
    required this.backPhotoCardId,
    required this.amount,
    required this.status,
  });

  @override
  String toString() => 'OrderCreationResult(orderId: $orderId, status: $status)';
}
