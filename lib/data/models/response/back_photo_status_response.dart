import 'package:freezed_annotation/freezed_annotation.dart';

part 'back_photo_status_response.freezed.dart';
part 'back_photo_status_response.g.dart';

@freezed
class BackPhotoStatusResponse with _$BackPhotoStatusResponse {
  const factory BackPhotoStatusResponse({
    required bool success,
  }) = _BackPhotoStatusResponse;

  factory BackPhotoStatusResponse.fromJson(Map<String, dynamic> json) => _$BackPhotoStatusResponseFromJson(json);
}