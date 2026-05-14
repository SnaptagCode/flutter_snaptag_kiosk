import 'package:flutter_snaptag_kiosk/lib.dart';

class PaymentHistoryScreenState {
  final OrderListResponse? orders;
  final bool hasLoadError;

  const PaymentHistoryScreenState({
    required this.orders,
    this.hasLoadError = false,
  });
}
