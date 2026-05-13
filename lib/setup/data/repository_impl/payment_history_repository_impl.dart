import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:flutter_snaptag_kiosk/setup/data/data_source/i_payment_history_remote_data_source.dart';
import 'package:flutter_snaptag_kiosk/setup/domain/repository/i_payment_history_repository.dart';

class PaymentHistoryRepositoryImpl implements IPaymentHistoryRepository {
  final IPaymentHistoryRemoteDataSource _dataSource;

  PaymentHistoryRepositoryImpl(this._dataSource);

  @override
  Future<OrderListResponse> getOrders(GetOrdersRequest request) {
    return _dataSource.getOrders(
      pageSize: request.pageSize,
      currentPage: request.currentPage,
      kioskMachineId: request.kioskMachineId,
    );
  }

  @override
  Future<void> updateOrderStatus(int orderId, UpdateOrderRequest request) {
    return _dataSource.updateOrderStatus(orderId, request);
  }
}
