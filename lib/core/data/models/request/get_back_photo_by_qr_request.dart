import 'package:freezed_annotation/freezed_annotation.dart';

part 'get_back_photo_by_qr_request.freezed.dart';
part 'get_back_photo_by_qr_request.g.dart';

@freezed
class GetBackPhotoByQrRequest with _$GetBackPhotoByQrRequest {
  const factory GetBackPhotoByQrRequest({
    required int kioskEventId,
    required int nominatedBackPhotoCardId,

    /// 뒷면 출력 스타일 'ORIGIN'(풀이미지) | 'FORMATTED'(라벨 이미지) — 대문자 전송 (JKLI-214)
    required String imageType,
  }) = _GetBackPhotoByQrRequest;

  factory GetBackPhotoByQrRequest.fromJson(Map<String, dynamic> json) => _$GetBackPhotoByQrRequestFromJson(json);
}

