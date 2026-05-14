import 'package:flutter_snaptag_kiosk/data/models/response/back_photo_card_response.dart';

abstract interface class IVerificationRemoteDataSource {
  Future<BackPhotoCardResponse> getBackPhotoCard({
    required int kioskEventId,
    required String photoAuthNumber,
  });
}
