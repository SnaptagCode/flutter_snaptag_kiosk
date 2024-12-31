// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nominated_photo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NominatedPhotoImpl _$$NominatedPhotoImplFromJson(Map<String, dynamic> json) =>
    _$NominatedPhotoImpl(
      id: (json['id'] as num).toInt(),
      embeddingProductId: (json['embeddingProductId'] as num).toInt(),
      embeddedUrl: json['embeddedUrl'] as String,
    );

Map<String, dynamic> _$$NominatedPhotoImplToJson(
        _$NominatedPhotoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'embeddingProductId': instance.embeddingProductId,
      'embeddedUrl': instance.embeddedUrl,
    };
