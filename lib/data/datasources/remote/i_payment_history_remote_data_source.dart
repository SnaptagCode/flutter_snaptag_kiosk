import 'package:flutter_snaptag_kiosk/data/models/models.dart';

abstract interface class IPaymentHistoryRemoteDataSource {
  Future<OrderListResponse> getOrders({
    required int pageSize,
    required int currentPage,
    int? kioskMachineId,
  });

  Future<void> updateOrderStatus(int orderId, UpdateOrderRequest request);
}
