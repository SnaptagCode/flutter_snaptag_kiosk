import 'package:flutter_snaptag_kiosk/data/models/enums/payment_type.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'post_order_request.freezed.dart';
part 'post_order_request.g.dart';

@freezed
class PostOrderRequest with _$PostOrderRequest {
  factory PostOrderRequest({
    required int kioskEventId,
    required int kioskMachineId,
    required String photoAuthNumber,
    required int amount,
    String? tradeNumber,
    String? uniqueNumber,
    required PaymentType paymentType,
  }) = _PostOrderRequest;

  factory PostOrderRequest.fromJson(Map<String, dynamic> json) => _$PostOrderRequestFromJson(json);
}
