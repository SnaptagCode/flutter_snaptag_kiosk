import 'package:flutter_snaptag_kiosk/lib.dart';

abstract interface class IPaymentHistoryRepository {
  Future<OrderListResponse> getOrders(GetOrdersRequest request);
  Future<void> updateOrderStatus(int orderId, UpdateOrderRequest request);
}
