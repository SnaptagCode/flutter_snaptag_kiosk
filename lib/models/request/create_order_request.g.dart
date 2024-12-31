// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_order_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CreateOrderRequestImpl _$$CreateOrderRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$CreateOrderRequestImpl(
      kioskEventId: (json['kioskEventId'] as num).toInt(),
      kioskMachineId: (json['kioskMachineId'] as num).toInt(),
      photoAuthNumber: json['photoAuthNumber'] as String,
      amount: (json['amount'] as num).toInt(),
      tradeNumber: json['tradeNumber'] as String?,
      uniqueNumber: json['uniqueNumber'] as String?,
      paymentType: $enumDecode(_$PaymentTypeEnumMap, json['paymentType']),
    );

Map<String, dynamic> _$$CreateOrderRequestImplToJson(
        _$CreateOrderRequestImpl instance) =>
    <String, dynamic>{
      'kioskEventId': instance.kioskEventId,
      'kioskMachineId': instance.kioskMachineId,
      'photoAuthNumber': instance.photoAuthNumber,
      'amount': instance.amount,
      'tradeNumber': instance.tradeNumber,
      'uniqueNumber': instance.uniqueNumber,
      'paymentType': _$PaymentTypeEnumMap[instance.paymentType]!,
    };

const _$PaymentTypeEnumMap = {
  PaymentType.card: 'CARD',
};
