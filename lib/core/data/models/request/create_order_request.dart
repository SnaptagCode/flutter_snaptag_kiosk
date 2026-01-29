import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/payment_type.dart';

part 'create_order_request.freezed.dart';
part 'create_order_request.g.dart';

@freezed
class CreateOrderRequest with _$CreateOrderRequest {
  const factory CreateOrderRequest({
    required int kioskEventId,
    required int kioskMachineId,
    required String photoAuthNumber,
    required int amount,
    String? tradeNumber,
    String? uniqueNumber,
    required PaymentType paymentType,
    bool? isSingleSided,
  }) = _CreateOrderRequest;

  factory CreateOrderRequest.fromJson(Map<String, dynamic> json) => _$CreateOrderRequestFromJson(json);
}
