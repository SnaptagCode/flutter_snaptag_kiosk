import 'package:flutter_snaptag_kiosk/lib.dart';

abstract interface class IKioskRepository {
  Future<CreateOrderResponse> createOrderStatus(CreateOrderRequest request);
  Future<UpdateOrderResponse> updateOrderStatus(int orderId, UpdateOrderRequest request);
}
