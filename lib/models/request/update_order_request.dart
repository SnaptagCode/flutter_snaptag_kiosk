import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/enums.dart';

part 'update_order_request.freezed.dart';
part 'update_order_request.g.dart';

@freezed
class UpdateOrderRequest with _$UpdateOrderRequest {
  const factory UpdateOrderRequest({
    required int kioskEventId,
    required int kioskMachineId,
    required String photoAuthNumber,
    required OrderStatus status,
    required int amount,
    required String purchaseAuthNumber,
    required String authSeqNumber,
    required String approvalNumber,
    String? tradeNumber,
    String? uniqueNumber,
    required String detail,
  }) = _UpdateOrderRequest;

  factory UpdateOrderRequest.fromJson(Map<String, dynamic> json) => _$UpdateOrderRequestFromJson(json);
}
