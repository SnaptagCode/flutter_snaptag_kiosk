import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'photo_card_preview_screen_provider.g.dart';

@riverpod
class PhotoCardPreview extends _$PhotoCardPreview {
  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }

  Future<void> _cleanup() async {
    ref.read(createOrderInfoProvider.notifier).reset();
    ref.read(paymentResponseStateProvider.notifier).reset();
    ref.read(verifyPhotoCardProvider.notifier).reset();
    ref.read(backPhotoForPrintInfoProvider.notifier).reset();
  }

  Future<void> payment() async {
    state = const AsyncValue.loading();
    try {
      logger.i('Starting payment process', time: DateTime.now());
      await ref.read(userOrderProcessProvider.notifier).startPayment();

      // 결제 성공시에만 상태 업데이트
      final userOrderState = ref.read(userOrderProcessProvider);
      if (userOrderState.hasError) {
        throw userOrderState.error!;
      }
      // 성공 시에는 cleanup하지 않음 - PrintProcess에서 provider 데이터 사용
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      // 결제 실패 시 즉시 환불 시도
      logger.e(
        'Payment process failed',
        error: e,
        stackTrace: stack,
        time: DateTime.now(),
      );
      try {
        logger.i('Starting refund process', time: DateTime.now());
        await ref.read(userOrderProcessProvider.notifier).startRefund();
        await _cleanup(); // 실패 시에만 cleanup 실행
        state = AsyncValue.error(e, stack);
      } catch (refundError, refundStack) {
        logger.e(
          'Critical: Payment failed and refund also failed',
          error: refundError,
          stackTrace: refundStack,
          time: DateTime.now(),
        );
        await _cleanup(); // 실패 시에만 cleanup 실행
        state = AsyncValue.error(
          Exception('시스템 오류가 발생했습니다. 관리자에게 문의해주세요.'),
          refundStack,
        );
      }
    }
  }
}
