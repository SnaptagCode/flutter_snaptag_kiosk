import 'package:flutter_snaptag_kiosk/data/datasources/remote/i_payment_history_remote_data_source.dart';
import 'package:flutter_snaptag_kiosk/data/models/request/update_order_request.dart';
import 'package:flutter_snaptag_kiosk/data/models/response/order_list_response.dart';
import 'package:flutter_snaptag_kiosk/domain/models/order/get_orders_params.dart';
import 'package:flutter_snaptag_kiosk/domain/models/order/order_list_result.dart';
import 'package:flutter_snaptag_kiosk/domain/models/order/update_order_params.dart';
import 'package:flutter_snaptag_kiosk/domain/repositories/i_payment_history_repository.dart';

class PaymentHistoryRepositoryImpl implements IPaymentHistoryRepository {
  final IPaymentHistoryRemoteDataSource _dataSource;

  PaymentHistoryRepositoryImpl(this._dataSource);

  @override
  Future<OrderListResult> getOrders(GetOrdersParams params) async {
    final response = await _dataSource.getOrders(
      pageSize: params.pageSize,
      currentPage: params.currentPage,
      kioskMachineId: params.kioskMachineId,
    );
    return response.toDomain();
  }

  @override
  Future<void> updateOrderStatus(int orderId, UpdateHistoryOrderParams params) {
    final request = UpdateOrderRequest(
      kioskEventId: params.kioskEventId,
      kioskMachineId: params.kioskMachineId,
      photoAuthNumber: params.photoAuthNumber,
      amount: params.amount,
      status: params.status,
      approvalNumber: params.approvalNumber,
      purchaseAuthNumber: params.purchaseAuthNumber,
      authSeqNumber: params.authSeqNumber,
      detail: params.detail,
      description: params.description,
    );
    return _dataSource.updateOrderStatus(orderId, request);
  }
}
