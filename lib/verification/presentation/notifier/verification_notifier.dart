import 'package:flutter_snaptag_kiosk/domain/models/verification/verification_failure.dart';
import 'package:flutter_snaptag_kiosk/presentation/core/back_photo_session_notifier.dart';
import 'package:flutter_snaptag_kiosk/presentation/kiosk_shell/kiosk_info_service.dart';
import 'package:flutter_snaptag_kiosk/verification/domain/usecase/verify_photo_code_use_case.dart';
import 'package:flutter_snaptag_kiosk/verification/module/verification_di.dart';
import 'package:flutter_snaptag_kiosk/verification/presentation/notifier/auth_code_notifier.dart';
import 'package:flutter_snaptag_kiosk/verification/presentation/notifier/verification_action.dart';
import 'package:flutter_snaptag_kiosk/verification/presentation/notifier/verification_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'verification_notifier.g.dart';

@Riverpod(keepAlive: true)
class VerificationNotifier extends _$VerificationNotifier {
  late final VerifyPhotoCodeUseCase _verifyPhotoCodeUseCase;

  @override
  VerificationState build() {
    _verifyPhotoCodeUseCase = ref.watch(verifyPhotoCodeUseCaseProvider);
    return const VerificationState.initial();
  }

  Future<void> onAction(VerificationAction action) async {
    switch (action) {
      case VerificationActionSubmit(:final code):
        await _verifyCode(code);
      case VerificationActionCancel():
        ref.read(authCodeProvider.notifier).clear();
        state = const VerificationState.initial();
    }
  }

  Future<void> _verifyCode(String code) async {
    final kioskEventId = ref.read(kioskInfoServiceProvider)?.kioskEventId;
    if (kioskEventId == null) {
      state = const VerificationState.failure(
        VerificationFailureUnknown('키오스크 이벤트 ID를 찾을 수 없습니다.'),
      );
      return;
    }

    state = const VerificationState.loading();

    try {
      final result = await _verifyPhotoCodeUseCase(
        VerifyPhotoCodeParams(kioskEventId: kioskEventId, authCode: code),
      );

      state = result.when(
        data: (card) {
          ref.read(backPhotoSessionProvider.notifier).updateState(card);
          return VerificationState.success(card);
        },
        error: (e, _) => VerificationState.failure(
          e is VerificationFailure ? e : VerificationFailureUnknown(e.toString()),
        ),
        loading: () => const VerificationState.loading(),
      );
    } catch (e) {
      state = VerificationState.failure(VerificationFailureUnknown(e.toString()));
    }
  }

  void reset() => state = const VerificationState.initial();
}
