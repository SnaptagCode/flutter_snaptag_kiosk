import 'package:flutter_snaptag_kiosk/domain/models/order/order_creation_result.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/enums.dart';

part 'create_order_response.freezed.dart';
part 'create_order_response.g.dart';

@freezed
class CreateOrderResponse with _$CreateOrderResponse {
  const factory CreateOrderResponse({
    required int orderId,
    required int kioskEventId,
    required int kioskMachineId,
    required int backPhotoCardId,
    required int amount,
    required OrderStatus status,
    required String paymentType,
  }) = _CreateOrderResponse;

  factory CreateOrderResponse.fromJson(Map<String, dynamic> json) => _$CreateOrderResponseFromJson(json);
}

extension CreateOrderResponseMapper on CreateOrderResponse {
  OrderCreationResult toDomain() => OrderCreationResult(
        orderId: orderId,
        kioskEventId: kioskEventId,
        kioskMachineId: kioskMachineId,
        backPhotoCardId: backPhotoCardId,
        amount: amount,
        status: status,
      );
}
