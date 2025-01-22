import 'package:freezed_annotation/freezed_annotation.dart';

part 'get_orders_request.freezed.dart';
part 'get_orders_request.g.dart';

@freezed
class GetOrdersRequest with _$GetOrdersRequest {
  const factory GetOrdersRequest({
    required int pageSize,
    required int currentPage,
  }) = _GetOrdersRequest;

  factory GetOrdersRequest.fromJson(Map<String, dynamic> json) => _$GetOrdersRequestFromJson(json);
  //toJson
}
