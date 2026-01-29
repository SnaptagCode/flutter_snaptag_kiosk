import 'package:flutter_snaptag_kiosk/core/data/data.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_order_response.freezed.dart';
part 'update_order_response.g.dart';

@freezed
class UpdateOrderResponse with _$UpdateOrderResponse {
  const factory UpdateOrderResponse({
    required int orderId,
    required int kioskEventId,
    required int kioskMachineId,
    required double amount,
    required OrderStatus status,
    required PaymentType paymentType,
    required int kioskPaymentRecordId,
  }) = _UpdateOrderResponse;

  factory UpdateOrderResponse.fromJson(Map<String, dynamic> json) => _$UpdateOrderResponseFromJson(json);
}
