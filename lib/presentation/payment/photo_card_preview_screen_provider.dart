import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:flutter_snaptag_kiosk/presentation/core/card_count_provider.dart';
import 'package:flutter_snaptag_kiosk/presentation/home/back_photo_type_provider.dart';
import 'package:flutter_snaptag_kiosk/presentation/kiosk_shell/home_timeout_provider.dart';
import 'package:flutter_snaptag_kiosk/presentation/kiosk_shell/kiosk_info_service.dart';
import 'package:flutter_snaptag_kiosk/presentation/setup/page_print_provider.dart';
import 'package:flutter_snaptag_kiosk/presentation/payment/payment_service.dart';
import 'package:flutter_snaptag_kiosk/presentation/verification/verify_photo_card_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'photo_card_preview_screen_provider.g.dart';

@riverpod
class PhotoCardPreviewScreenProvider extends _$PhotoCardPreviewScreenProvider {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<void> payment() async {
    // 이미 로딩 중이면 중복 요청 방지
    if (state.isLoading) {
      return;
    }

    state = const AsyncValue.loading();

    try {
      // // 선택된 뒷면 이미지 타입 확인
      final selection = ref.read(backPhotoTypeProvider);

      if (selection?.type == BackPhotoType.fixed && selection?.fixedIndex != null) {
        // 고정 뒷면 이미지 결제 처리
        final kiosk = ref.read(kioskInfoServiceProvider);
        final selectedIndex = selection!.fixedIndex!;

        if (kiosk != null && selectedIndex < kiosk.nominatedBackPhotoCardList.length) {
          final selectedCard = kiosk.nominatedBackPhotoCardList[selectedIndex];

          final response = await ref.read(kioskRepositoryProvider).getBackPhotoCardByQr(
                GetBackPhotoByQrRequest(
                  kioskEventId: kiosk.kioskEventId,
                  nominatedBackPhotoCardId: selectedCard.id,
                ),
              );

          ref.read(verifyPhotoCardProvider.notifier).updateState(BackPhotoCardResponse(
              kioskEventId: kiosk.kioskEventId,
              backPhotoCardId: response.backPhotoCardId,
              backPhotoCardOriginUrl: selectedCard.originUrl,
              photoAuthNumber: response.photoAuthNumber,
              formattedBackPhotoCardUrl: response.formattedBackPhotoCardUrl));
        }
      }

      final timeoutNotifier = ref.read(homeTimeoutNotifierProvider.notifier);
      timeoutNotifier.cancelTimerWithCallback();

      await ref.read(paymentServiceProvider.notifier).processPayment();

      state = const AsyncValue.data(null);
    } catch (e, stack) {
      if (e is! OrderCreationException && e is! PreconditionFailedException) {
        try {
          await ref.read(paymentServiceProvider.notifier).refund();
          if (ref.read(pagePrintProvider) == PagePrintType.single) {
            await ref.read(cardCountProvider.notifier).increase();
          }
        } catch (refundError) {
          logger.e('Payment and refund failed', error: refundError);
        }
      }
      state = AsyncValue.error(e, stack);
    }
  }
}
