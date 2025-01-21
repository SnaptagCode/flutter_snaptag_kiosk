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
      // 1. 주문 생성
      await ref.read(paymentServiceProvider.notifier).createOrder();

      // 2. 결제 승인 요청
      await ref.read(paymentServiceProvider.notifier).approvePayment();

      // 3. 결제 완료 상태로 업데이트
      await ref.read(paymentServiceProvider.notifier).updateOrder(OrderStatus.completed);

      // 4. 결제 완료 후 상태 갱신
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      await _handlePaymentFailure(e, stack);
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> _handlePaymentFailure(Object error, StackTrace stack) async {
    try {
      // 1. 실패 상태로 주문 업데이트
      await ref.read(paymentServiceProvider.notifier).updateOrder(OrderStatus.failed);

      // 2. 결제 취소 시도
      await ref.read(paymentServiceProvider.notifier).cancelPayment();

      // 3. 환불 완료로 상태 업데이트
      await ref.read(paymentServiceProvider.notifier).updateOrder(OrderStatus.refunded);
    } catch (cancelError) {
      // 결제 취소 실패 시 로그 기록
      logger.e('Payment cancellation failed', error: cancelError);
      await ref.read(paymentServiceProvider.notifier).updateOrder(OrderStatus.refunded_failed);
    }
  }
}
