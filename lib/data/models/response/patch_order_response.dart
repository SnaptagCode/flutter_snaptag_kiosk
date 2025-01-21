import 'package:flutter_snaptag_kiosk/data/data.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'patch_order_response.freezed.dart';
part 'patch_order_response.g.dart';

@freezed
class PatchOrderResponse with _$PatchOrderResponse {
  const factory PatchOrderResponse({
    required int orderId,
    required int kioskEventId,
    required int kioskMachineId,
    required double amount,
    required OrderStatus status,
    required PaymentType paymentType,
    required int kioskPaymentRecordId,
    required BackPhotoForPrint backPhotoForPrint,
  }) = _PatchOrderResponse;

  factory PatchOrderResponse.fromJson(Map<String, dynamic> json) => _$PatchOrderResponseFromJson(json);
}
