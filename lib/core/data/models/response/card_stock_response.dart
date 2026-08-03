import 'package:freezed_annotation/freezed_annotation.dart';

part 'card_stock_response.freezed.dart';
part 'card_stock_response.g.dart';

/// [cardCapacity]는 머신에 미설정일 수 있어 nullable로 둔다.
/// 응답의 `slackNotified`는 KIOSK에서 항상 false라 파싱하지 않는다.
@freezed
class CardStockResponse with _$CardStockResponse {
  const factory CardStockResponse({
    @Default(0) int id,
    @Default('') String name,
    @Default(0) int cardCurrentCount,
    int? cardCapacity,
  }) = _CardStockResponse;

  factory CardStockResponse.fromJson(Map<String, dynamic> json) => _$CardStockResponseFromJson(json);
}
