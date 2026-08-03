import 'package:freezed_annotation/freezed_annotation.dart';

part 'card_stock_set_request.freezed.dart';
part 'card_stock_set_request.g.dart';

/// [machineId] / [uniqueKey] 중 하나는 반드시 있어야 한다.
/// [requestCount]는 가산이 아닌 절대값이다(0 = CLEAR).
@freezed
class CardStockSetRequest with _$CardStockSetRequest {
  const factory CardStockSetRequest({
    @JsonKey(includeIfNull: false) int? machineId,
    @JsonKey(includeIfNull: false) String? uniqueKey,
    required int requestCount,
  }) = _CardStockSetRequest;

  factory CardStockSetRequest.fromJson(Map<String, dynamic> json) => _$CardStockSetRequestFromJson(json);
}
