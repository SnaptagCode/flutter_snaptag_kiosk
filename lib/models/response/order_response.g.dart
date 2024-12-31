// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$OrderResponseImpl _$$OrderResponseImplFromJson(Map<String, dynamic> json) =>
    _$OrderResponseImpl(
      orderId: (json['orderId'] as num).toInt(),
      kioskEventId: (json['kioskEventId'] as num).toInt(),
      kioskMachineId: (json['kioskMachineId'] as num).toInt(),
      amount: (json['amount'] as num).toDouble(),
      status: json['status'] as String,
      paymentType: json['paymentType'] as String,
    );

Map<String, dynamic> _$$OrderResponseImplToJson(_$OrderResponseImpl instance) =>
    <String, dynamic>{
      'orderId': instance.orderId,
      'kioskEventId': instance.kioskEventId,
      'kioskMachineId': instance.kioskMachineId,
      'amount': instance.amount,
      'status': instance.status,
      'paymentType': instance.paymentType,
    };
