import 'package:flutter_snaptag_kiosk/core/data/models/enums/enums.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'order_entity.freezed.dart';
part 'order_entity.g.dart';

@freezed
class OrderEntity with _$OrderEntity {
  factory OrderEntity({
    required int orderId,
    required int kioskMachineId,
    required String eventName,
    required String photoAuthNumber,
    required String? paymentAuthNumber,
    required double amount,
    required DateTime? completedAt,
    required DateTime? refundedAt,
    required OrderStatus orderStatus,
    required PrintedStatus printedStatus,
  }) = _OrderEntity;

  factory OrderEntity.fromJson(Map<String, dynamic> json) => _$OrderEntityFromJson(json);
}
