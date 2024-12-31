// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nominated_photo_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NominatedPhotoListImpl _$$NominatedPhotoListImplFromJson(
        Map<String, dynamic> json) =>
    _$NominatedPhotoListImpl(
      list: (json['list'] as List<dynamic>)
          .map((e) => NominatedPhoto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$NominatedPhotoListImplToJson(
        _$NominatedPhotoListImpl instance) =>
    <String, dynamic>{
      'list': instance.list,
    };
