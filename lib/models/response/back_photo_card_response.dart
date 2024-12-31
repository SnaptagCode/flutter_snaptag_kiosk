import 'package:freezed_annotation/freezed_annotation.dart';

part 'back_photo_card_response.freezed.dart';
part 'back_photo_card_response.g.dart';

@freezed
class BackPhotoCardResponse with _$BackPhotoCardResponse {
  const factory BackPhotoCardResponse({
    required int kioskEventId,
    required int backPhotoCardId,
    int? nominatedBackPhotoCardId,
    required int embeddingProductId,
    required String photoAuthNumber,
    required String backPhotoCardOriginUrl,
    required String formattedBackPhotoCardUrl,
  }) = _BackPhotoCardResponse;

  factory BackPhotoCardResponse.fromJson(Map<String, dynamic> json) => _$BackPhotoCardResponseFromJson(json);
}
