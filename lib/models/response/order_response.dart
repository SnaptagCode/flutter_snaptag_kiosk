import 'package:flutter_snaptag_kiosk/models/entities/order_entity.dart';
import 'package:flutter_snaptag_kiosk/models/entities/paging_entity.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'order_response.freezed.dart';
part 'order_response.g.dart';

@freezed
class OrderResponse with _$OrderResponse {
  factory OrderResponse({
    required List<OrderEntity> list,
    required PagingEntity paging,
  }) = _OrderResponse;

  factory OrderResponse.fromJson(Map<String, dynamic> json) => _$OrderResponseFromJson(json);
}
