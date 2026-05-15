import 'package:flutter_snaptag_kiosk/data/datasources/remote/i_payment_history_remote_data_source.dart';
import 'package:flutter_snaptag_kiosk/data/datasources/remote/kiosk_api_client.dart';
import 'package:flutter_snaptag_kiosk/data/models/models.dart';

class PaymentHistoryRemoteDataSourceImpl implements IPaymentHistoryRemoteDataSource {
  final KioskApiClient _apiClient;

  PaymentHistoryRemoteDataSourceImpl(this._apiClient);

  @override
  Future<OrderListResponse> getOrders({
    required int pageSize,
    required int currentPage,
    int? kioskMachineId,
  }) {
    return _apiClient.getOrders(
      pageSize: pageSize,
      currentPage: currentPage,
      kioskMachineId: kioskMachineId,
    );
  }

  @override
  Future<void> updateOrderStatus(int orderId, UpdateOrderRequest request) async {
    await _apiClient.updateOrder(orderId: orderId, body: request.toJson());
  }
}
