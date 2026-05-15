import 'package:flutter_snaptag_kiosk/domain/models/order/get_orders_params.dart';
import 'package:flutter_snaptag_kiosk/domain/models/order/order_list_result.dart';
import 'package:flutter_snaptag_kiosk/domain/models/order/update_order_params.dart';

abstract interface class IPaymentHistoryRepository {
  Future<OrderListResult> getOrders(GetOrdersParams params);
  Future<void> updateOrderStatus(int orderId, UpdateHistoryOrderParams params);
}
