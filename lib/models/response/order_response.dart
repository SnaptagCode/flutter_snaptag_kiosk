import 'package:freezed_annotation/freezed_annotation.dart';

part 'order_response.freezed.dart';
part 'order_response.g.dart';

@freezed
class OrderResponse with _$OrderResponse {
  const factory OrderResponse({
    required int orderId,
    required int kioskEventId,
    required int kioskMachineId,
    // required int backPhotoCardId,
    required double amount,
    required String status,
    required String paymentType,
    //required int kioskPaymentRecordId, //TODO:CHECK
  }) = _OrderResponse;

  factory OrderResponse.fromJson(Map<String, dynamic> json) => _$OrderResponseFromJson(json);
}
