import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'photo_card_preview.g.dart';

@riverpod
class PhotoCardPreview extends _$PhotoCardPreview {
  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }

  Future<void> payment() async {
    state = const AsyncValue.loading();
    try {
      await ref.read(userOrderProcessProvider.notifier).startPayment();
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      // 결제 실패 시 즉시 환불 시도
      try {
        await ref.read(userOrderProcessProvider.notifier).startRefund();
        // 환불 성공 - 원래 에러를 표시
        state = AsyncValue.error(e, stack);
      } catch (refundError, refundStack) {
        // 환불 실패 - 더 심각한 상황
        logger.e(
          'Payment failed and refund also failed',
          error: refundError,
          stackTrace: refundStack,
        );
        state = AsyncValue.error(
          Exception('Payment failed and refund also failed: $refundError'),
          refundStack,
        );
      }
    }
  }
}
