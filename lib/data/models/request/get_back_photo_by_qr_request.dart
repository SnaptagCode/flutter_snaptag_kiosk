import 'package:freezed_annotation/freezed_annotation.dart';

part 'get_back_photo_by_qr_request.freezed.dart';
part 'get_back_photo_by_qr_request.g.dart';

@freezed
class GetBackPhotoByQrRequest with _$GetBackPhotoByQrRequest {
  const factory GetBackPhotoByQrRequest({
    required int kioskEventId,
    required int nominatedBackPhotoCardId,
  }) = _GetBackPhotoByQrRequest;

  factory GetBackPhotoByQrRequest.fromJson(Map<String, dynamic> json) => _$GetBackPhotoByQrRequestFromJson(json);
}

