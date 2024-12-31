// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_order_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UpdateOrderRequestImpl _$$UpdateOrderRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$UpdateOrderRequestImpl(
      kioskEventId: (json['kioskEventId'] as num).toInt(),
      kioskMachineId: (json['kioskMachineId'] as num).toInt(),
      photoAuthNumber: json['photoAuthNumber'] as String,
      status: $enumDecode(_$OrderStatusEnumMap, json['status']),
      amount: (json['amount'] as num).toInt(),
      purchaseAuthNumber: json['purchaseAuthNumber'] as String,
      authSeqNumber: json['authSeqNumber'] as String,
      approvalNumber: json['approvalNumber'] as String,
      tradeNumber: json['tradeNumber'] as String?,
      uniqueNumber: json['uniqueNumber'] as String?,
      detail: json['detail'] as String,
    );

Map<String, dynamic> _$$UpdateOrderRequestImplToJson(
        _$UpdateOrderRequestImpl instance) =>
    <String, dynamic>{
      'kioskEventId': instance.kioskEventId,
      'kioskMachineId': instance.kioskMachineId,
      'photoAuthNumber': instance.photoAuthNumber,
      'status': _$OrderStatusEnumMap[instance.status]!,
      'amount': instance.amount,
      'purchaseAuthNumber': instance.purchaseAuthNumber,
      'authSeqNumber': instance.authSeqNumber,
      'approvalNumber': instance.approvalNumber,
      'tradeNumber': instance.tradeNumber,
      'uniqueNumber': instance.uniqueNumber,
      'detail': instance.detail,
    };

const _$OrderStatusEnumMap = {
  OrderStatus.pending: 'PENDING',
  OrderStatus.failed: 'FAILED',
  OrderStatus.completed: 'COMPLETED',
  OrderStatus.refunded: 'REFUNDED',
  OrderStatus.refundedFailed: 'REFUNDED_FAILED',
};
