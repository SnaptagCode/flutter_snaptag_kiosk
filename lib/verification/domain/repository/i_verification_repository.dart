import 'package:flutter_snaptag_kiosk/core/result/result.dart';
import 'package:flutter_snaptag_kiosk/domain/models/verification/back_photo_card.dart';
import 'package:flutter_snaptag_kiosk/domain/models/verification/verification_failure.dart';

abstract interface class IVerificationRepository {
  Future<Result<BackPhotoCard, VerificationFailure>> verifyCode({
    required int kioskEventId,
    required String authCode,
  });
}
