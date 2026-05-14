import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_snaptag_kiosk/core/usecase/usecase.dart';
import 'package:flutter_snaptag_kiosk/domain/models/verification/back_photo_card.dart';
import 'package:flutter_snaptag_kiosk/verification/domain/repository/i_verification_repository.dart';

class VerifyPhotoCodeParams {
  final int kioskEventId;
  final String authCode;
  const VerifyPhotoCodeParams({required this.kioskEventId, required this.authCode});
}

class VerifyPhotoCodeUseCase implements UseCase<BackPhotoCard, VerifyPhotoCodeParams> {
  final IVerificationRepository _repository;

  VerifyPhotoCodeUseCase(this._repository);

  @override
  Future<AsyncValue<BackPhotoCard>> call(VerifyPhotoCodeParams params) async {
    final result = await _repository.verifyCode(
      kioskEventId: params.kioskEventId,
      authCode: params.authCode,
    );
    return result.when(
      success: (card) => AsyncValue.data(card),
      failure: (failure) => AsyncValue.error(failure, StackTrace.current),
    );
  }
}
