import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/enums.dart';

part 'post_order_response.freezed.dart';
part 'post_order_response.g.dart';

@freezed
class PostOrderResponse with _$PostOrderResponse {
  const factory PostOrderResponse({
    required int orderId,
    required int kioskEventId,
    required int kioskMachineId,
    required int backPhotoCardId,
    required int amount,
    required OrderStatus status,
    required String paymentType,
  }) = _PostOrderResponse;

  factory PostOrderResponse.fromJson(Map<String, dynamic> json) => _$PostOrderResponseFromJson(json);
}
