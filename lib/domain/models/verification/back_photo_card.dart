import 'package:freezed_annotation/freezed_annotation.dart';

part 'back_photo_card.freezed.dart';

@freezed
class BackPhotoCard with _$BackPhotoCard {
  const factory BackPhotoCard({
    required int kioskEventId,
    required int backPhotoCardId,
    int? nominatedBackPhotoCardId,
    required String backPhotoCardOriginUrl,
    required String photoAuthNumber,
    int? embeddingProductId,
    required String formattedBackPhotoCardUrl,
  }) = _BackPhotoCard;
}
