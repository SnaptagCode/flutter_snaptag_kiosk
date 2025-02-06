import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'photo_card_preview_screen_provider.g.dart';

@riverpod
class PhotoCardPreviewScreenProvider extends _$PhotoCardPreviewScreenProvider {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<void> payment() async {
    state = const AsyncValue.loading();

    try {
      await ref.read(paymentServiceProvider.notifier).processPayment();
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      try {
        await ref.read(paymentServiceProvider.notifier).refund();
      } catch (refundError) {
        FileLogger.warning('Payment and refund failed', error: refundError);
      }
      state = AsyncValue.error(e, stack);
    }
  }
}
