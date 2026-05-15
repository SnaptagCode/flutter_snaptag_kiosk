import 'package:flutter_snaptag_kiosk/data/models/enums/enums.dart';
import 'package:flutter_snaptag_kiosk/domain/models/order/order_data.dart';
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
    required PrintedStatus? printedStatus,
  }) = _OrderEntity;

  factory OrderEntity.fromJson(Map<String, dynamic> json) => _$OrderEntityFromJson(json);
}

extension OrderEntityMapper on OrderEntity {
  OrderData toDomain() => OrderData(
        orderId: orderId,
        kioskMachineId: kioskMachineId,
        eventName: eventName,
        photoAuthNumber: photoAuthNumber,
        paymentAuthNumber: paymentAuthNumber,
        amount: amount,
        completedAt: completedAt,
        refundedAt: refundedAt,
        orderStatus: orderStatus,
        printedStatus: printedStatus,
      );
}
