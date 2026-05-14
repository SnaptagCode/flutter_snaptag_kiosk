import 'package:freezed_annotation/freezed_annotation.dart';

part 'order_error_entity.freezed.dart';
part 'order_error_entity.g.dart';

@freezed
class OrderErrorEntity with _$OrderErrorEntity {
  factory OrderErrorEntity({
    required int? orderId,
    required String? authSeqNumber,
    required DateTime? completedAt,
  }) = _OrderErrorEntity;

  factory OrderErrorEntity.fromJson(Map<String, dynamic> json) =>
      _$OrderErrorEntityFromJson(json);
}