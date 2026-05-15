import 'package:flutter_snaptag_kiosk/domain/models/order/get_orders_params.dart';
import 'package:flutter_snaptag_kiosk/domain/models/order/order_list_result.dart';
import 'package:flutter_snaptag_kiosk/domain/repositories/i_payment_history_repository.dart';
import 'package:flutter_snaptag_kiosk/domain/usecase.dart';

class GetOrdersUseCase implements UseCase<OrderListResult, GetOrdersParams> {
  final IPaymentHistoryRepository _repository;

  GetOrdersUseCase(this._repository);

  @override
  Future<OrderListResult> call(GetOrdersParams params) {
    return _repository.getOrders(params);
  }
}
