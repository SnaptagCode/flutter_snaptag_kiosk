import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_back_photo_request.freezed.dart';
part 'update_back_photo_request.g.dart';

@freezed
class UpdateBackPhotoRequest with _$UpdateBackPhotoRequest {
  const factory UpdateBackPhotoRequest({
    required String photoAuthNumber,
    required String status,
  }) = _UpdateBackPhotoRequest;

  factory UpdateBackPhotoRequest.fromJson(Map<String, dynamic> json) => _$UpdateBackPhotoRequestFromJson(json);
}
