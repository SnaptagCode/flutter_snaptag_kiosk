import 'package:flutter_snaptag_kiosk/data/datasources/remote/kiosk_api_client.dart';
import 'package:flutter_snaptag_kiosk/data/models/response/back_photo_card_response.dart';
import 'package:flutter_snaptag_kiosk/verification/data/data_source/i_verification_remote_data_source.dart';

class VerificationRemoteDataSourceImpl implements IVerificationRemoteDataSource {
  final KioskApiClient _apiClient;

  VerificationRemoteDataSourceImpl(this._apiClient);

  @override
  Future<BackPhotoCardResponse> getBackPhotoCard({
    required int kioskEventId,
    required String photoAuthNumber,
  }) {
    return _apiClient.getBackPhotoCard(
      kioskEventId: kioskEventId,
      photoAuthNumber: photoAuthNumber,
    );
  }
}
