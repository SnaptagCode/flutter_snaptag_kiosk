import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_snaptag_kiosk/core/usecase/usecase.dart';
import 'package:flutter_snaptag_kiosk/data/repositories/verification_repository_impl.dart';
import 'package:flutter_snaptag_kiosk/domain/models/verification/back_photo_card.dart';
import 'package:flutter_snaptag_kiosk/domain/repositories/verification_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'verify_photo_code_usecase.g.dart';

class VerifyPhotoCodeParams {
  final int kioskEventId;
  final String authCode;
  const VerifyPhotoCodeParams({required this.kioskEventId, required this.authCode});
}

class VerifyPhotoCodeUseCase implements UseCase<BackPhotoCard, VerifyPhotoCodeParams> {
  final VerificationRepository _repository;

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

@riverpod
VerifyPhotoCodeUseCase verifyPhotoCodeUseCase(Ref ref) {
  return VerifyPhotoCodeUseCase(ref.watch(verificationRepositoryProvider));
}
