import 'package:flutter_snaptag_kiosk/core/data/models/response/back_photo_card_response.dart';
import 'package:flutter_snaptag_kiosk/domain/models/verification/back_photo_card.dart';

extension BackPhotoCardResponseMapper on BackPhotoCardResponse {
  BackPhotoCard toModel() => BackPhotoCard(
        kioskEventId: kioskEventId,
        backPhotoCardId: backPhotoCardId,
        nominatedBackPhotoCardId: nominatedBackPhotoCardId,
        backPhotoCardOriginUrl: backPhotoCardOriginUrl,
        photoAuthNumber: photoAuthNumber,
        embeddingProductId: embeddingProductId,
        formattedBackPhotoCardUrl: formattedBackPhotoCardUrl,
      );
}

extension BackPhotoCardMapper on BackPhotoCard {
  BackPhotoCardResponse toResponse() => BackPhotoCardResponse(
        kioskEventId: kioskEventId,
        backPhotoCardId: backPhotoCardId,
        nominatedBackPhotoCardId: nominatedBackPhotoCardId,
        backPhotoCardOriginUrl: backPhotoCardOriginUrl,
        photoAuthNumber: photoAuthNumber,
        embeddingProductId: embeddingProductId,
        formattedBackPhotoCardUrl: formattedBackPhotoCardUrl,
      );
}
