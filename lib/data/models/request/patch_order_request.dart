import 'package:flutter_snaptag_kiosk/data/models/enums/order_status.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'patch_order_request.freezed.dart';
part 'patch_order_request.g.dart';

@freezed
class PatchOrderRequest with _$PatchOrderRequest {
  factory PatchOrderRequest({
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
    @Default('{}') String detail,
  }) = _PatchOrderRequest;

  factory PatchOrderRequest.fromJson(Map<String, dynamic> json) => _$PatchOrderRequestFromJson(json);
}
