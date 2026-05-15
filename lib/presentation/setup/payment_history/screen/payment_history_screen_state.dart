import 'package:flutter_snaptag_kiosk/domain/models/order/order_list_result.dart';

class PaymentHistoryScreenState {
  final OrderListResult? orders;
  final bool hasLoadError;

  const PaymentHistoryScreenState({
    required this.orders,
    this.hasLoadError = false,
  });
}
