import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:flutter_snaptag_kiosk/domain/repositories/i_payment_history_repository.dart';

class GetOrdersUseCase {
  final IPaymentHistoryRepository _repository;

  GetOrdersUseCase(this._repository);

  Future<OrderListResponse> call(GetOrdersRequest request) {
    return _repository.getOrders(request);
  }
}
