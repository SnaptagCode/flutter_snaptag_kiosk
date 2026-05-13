import 'package:flutter_snaptag_kiosk/data/mappers/verification_mapper.dart';
import 'package:flutter_snaptag_kiosk/domain/models/verification/verification_failure.dart';
import 'package:flutter_snaptag_kiosk/domain/usecases/verification/verify_photo_code_usecase.dart';
import 'package:flutter_snaptag_kiosk/presentation/kiosk_shell/kiosk_info_service.dart';
import 'package:flutter_snaptag_kiosk/presentation/verification/notifiers/verification_state.dart';
import 'package:flutter_snaptag_kiosk/presentation/verification/notifiers/verify_photo_card_notifier.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'verification_notifier.g.dart';

@Riverpod(keepAlive: true)
class VerificationNotifier extends _$VerificationNotifier {
  @override
  VerificationState build() => const VerificationState.initial();

  Future<void> verifyCode(String code) async {
    final kioskEventId = ref.read(kioskInfoServiceProvider)?.kioskEventId;
    if (kioskEventId == null) {
      state = const VerificationState.failure(
        VerificationFailureUnknown('키오스크 이벤트 ID를 찾을 수 없습니다.'),
      );
      return;
    }

    state = const VerificationState.loading();

    final result = await ref.read(verifyPhotoCodeUseCaseProvider)(
      VerifyPhotoCodeParams(kioskEventId: kioskEventId, authCode: code),
    );

    state = result.when(
      data: (card) {
        // Bridge: Phase 3/4 리팩토링 전까지 결제·프린트 레이어가 기존 provider를 사용
        ref.read(verifyPhotoCardProvider.notifier).updateState(card.toResponse());
        return VerificationState.success(card);
      },
      error: (e, _) => VerificationState.failure(e as VerificationFailure),
      loading: () => const VerificationState.loading(),
    );
  }

  void reset() => state = const VerificationState.initial();
}
