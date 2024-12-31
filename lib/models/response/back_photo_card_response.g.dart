// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'back_photo_card_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BackPhotoCardResponseImpl _$$BackPhotoCardResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$BackPhotoCardResponseImpl(
      kioskEventId: (json['kioskEventId'] as num).toInt(),
      backPhotoCardId: (json['backPhotoCardId'] as num).toInt(),
      nominatedBackPhotoCardId:
          (json['nominatedBackPhotoCardId'] as num?)?.toInt(),
      embeddingProductId: (json['embeddingProductId'] as num).toInt(),
      photoAuthNumber: json['photoAuthNumber'] as String,
      backPhotoCardOriginUrl: json['backPhotoCardOriginUrl'] as String,
      formattedBackPhotoCardUrl: json['formattedBackPhotoCardUrl'] as String,
    );

Map<String, dynamic> _$$BackPhotoCardResponseImplToJson(
        _$BackPhotoCardResponseImpl instance) =>
    <String, dynamic>{
      'kioskEventId': instance.kioskEventId,
      'backPhotoCardId': instance.backPhotoCardId,
      'nominatedBackPhotoCardId': instance.nominatedBackPhotoCardId,
      'embeddingProductId': instance.embeddingProductId,
      'photoAuthNumber': instance.photoAuthNumber,
      'backPhotoCardOriginUrl': instance.backPhotoCardOriginUrl,
      'formattedBackPhotoCardUrl': instance.formattedBackPhotoCardUrl,
    };
