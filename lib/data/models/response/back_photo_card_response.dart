import 'package:freezed_annotation/freezed_annotation.dart';

part 'back_photo_card_response.freezed.dart';
part 'back_photo_card_response.g.dart';

@freezed
class BackPhotoCardResponse with _$BackPhotoCardResponse {
  const factory BackPhotoCardResponse({
    required int kioskEventId,
    required int backPhotoCardId,
    int? nominatedBackPhotoCardId,
    required String backPhotoCardOriginUrl,
    required String photoAuthNumber,
    int? embeddingProductId,
    required String formattedBackPhotoCardUrl,
    required String status,
    required int seq
  }) = _BackPhotoCardResponse;

  factory BackPhotoCardResponse.fromJson(Map<String, dynamic> json) => _$BackPhotoCardResponseFromJson(json);
}
