import 'package:flutter_snaptag_kiosk/core/data/models/enums/order_status.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_order_request.freezed.dart';
part 'update_order_request.g.dart';

@freezed
class UpdateOrderRequest with _$UpdateOrderRequest {
  factory UpdateOrderRequest({
    required int kioskEventId,
    required int kioskMachineId,
    required String photoAuthNumber,
    required OrderStatus status,
    required int amount,
    required String purchaseAuthNumber,
    String? tradeNumber,
    String? uniqueNumber,
    required String authSeqNumber,
    required String approvalNumber,
    String? description,
    @Default('{}') String detail,
  }) = _UpdateOrderRequest;

  factory UpdateOrderRequest.fromJson(Map<String, dynamic> json) => _$UpdateOrderRequestFromJson(json);
}
