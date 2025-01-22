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

      // 결제 성공시에만 상태 업데이트
      final userOrderState = ref.read(userOrderProcessProvider);
      if (userOrderState.hasError) {
        throw userOrderState.error!;
      }

      state = const AsyncValue.data(null);
    } catch (e, stack) {
      // 결제 실패 시 즉시 환불 시도
      try {
        await ref.read(userOrderProcessProvider.notifier).startRefund();
        state = AsyncValue.error(e, stack);
      } catch (refundError, refundStack) {
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
