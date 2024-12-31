// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_print_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UpdatePrintResponseImpl _$$UpdatePrintResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$UpdatePrintResponseImpl(
      kioskEventId: (json['kioskEventId'] as num).toInt(),
      backPhotoId: (json['backPhotoId'] as num).toInt(),
      status: $enumDecode(_$PrintStatusEnumMap, json['status']),
      isEmbedded: json['isEmbedded'] as bool,
      printedPhotoCardId: (json['printedPhotoCardId'] as num).toInt(),
    );

Map<String, dynamic> _$$UpdatePrintResponseImplToJson(
        _$UpdatePrintResponseImpl instance) =>
    <String, dynamic>{
      'kioskEventId': instance.kioskEventId,
      'backPhotoId': instance.backPhotoId,
      'status': _$PrintStatusEnumMap[instance.status]!,
      'isEmbedded': instance.isEmbedded,
      'printedPhotoCardId': instance.printedPhotoCardId,
    };

const _$PrintStatusEnumMap = {
  PrintStatus.pending: 'PENDING',
  PrintStatus.started: 'STARTED',
  PrintStatus.completed: 'COMPLETED',
  PrintStatus.failed: 'FAILED',
  PrintStatus.refundedAfterPrinted: 'REFUNDED_AFTER_PRINTED',
  PrintStatus.refundedBeforePrinted: 'REFUNDED_BEFORE_PRINTED',
};
