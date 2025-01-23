import 'package:flutter_snaptag_kiosk/data/models/entities/order_entity.dart';
import 'package:flutter_snaptag_kiosk/data/models/entities/paging_entity.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'order_list_response.freezed.dart';
part 'order_list_response.g.dart';

@freezed
class OrderListResponse with _$OrderListResponse {
  factory OrderListResponse({
    required List<OrderEntity> list,
    required PagingEntity paging,
  }) = _OrderListResponse;

  factory OrderListResponse.fromJson(Map<String, dynamic> json) => _$OrderListResponseFromJson(json);
}
