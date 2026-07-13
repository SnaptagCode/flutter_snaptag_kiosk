import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:flutter_snaptag_kiosk/presentation/core/card_count_provider.dart';
import 'package:flutter_snaptag_kiosk/presentation/home/back_photo_type_provider.dart';
import 'package:flutter_snaptag_kiosk/presentation/kiosk_shell/home_timeout_provider.dart';
import 'package:flutter_snaptag_kiosk/presentation/kiosk_shell/kiosk_info_service.dart';
import 'package:flutter_snaptag_kiosk/presentation/payment/payment_failed_type.dart';
import 'package:flutter_snaptag_kiosk/presentation/payment/payment_service.dart';
import 'package:flutter_snaptag_kiosk/presentation/print/card_printer.dart';
import 'package:flutter_snaptag_kiosk/presentation/setup/page_print_provider.dart';
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

    // 결제 전 카드 피더 체크 - 카드가 없으면 결제 시도 없이 즉시 에러 처리
    try {
      await ref.read(printerServiceProvider.notifier).checkFeeder();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return;
    }

    try {
      // // 선택된 뒷면 이미지 타입 확인
      final selection = ref.read(backPhotoTypeProvider);

      if (selection?.type == BackPhotoType.fixed && selection?.fixedIndex != null) {
        // 고정 뒷면 이미지 결제 처리
        final kiosk = ref.read(kioskInfoServiceProvider);
        final selectedIndex = selection!.fixedIndex!;

        if (kiosk != null && selectedIndex < kiosk.nominatedBackPhotoCardList.length) {
          final selectedCard = kiosk.nominatedBackPhotoCardList[selectedIndex];

          // 스타일 미선택(null) 보정: 한화는 풀이미지(ORIGIN), 그 외는 라벨(FORMATTED) — 화면 기본 선택과 동일 규칙
          final layoutType = selection.effectiveLayoutType(isHwe: kiosk.isHwe);

          final response = await ref.read(kioskRepositoryProvider).getBackPhotoCardByQr(
                GetBackPhotoByQrRequest(
                  kioskEventId: kiosk.kioskEventId,
                  nominatedBackPhotoCardId: selectedCard.id,
                  imageType: layoutType.imageType,
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
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return;
    }

    try {
      await ref.read(paymentServiceProvider.notifier).processPayment();

      state = const AsyncValue.data(null);
    } catch (e, stack) {
      if (e is! OrderCreationException &&
          e is! PreconditionFailedException &&
          e is! EmptyApprovalNumberException &&
          e is! CancelledPaymentException &&
          e is! TimeoutPaymentException &&
          e is! UnknownPaymentException) {
        // 결제 승인 후 후속 처리 실패 → 자동환불 시도. 결과(성공/실패)를 화면에 전달해
        // 사용자가 환불 여부를 알 수 있게 한다.
        RefundResult refundResult;
        try {
          refundResult = await ref.read(paymentServiceProvider.notifier).refund();
          // 인쇄되지 않은 카드 수량 복구는 환불이 실제 성공했을 때만 반영한다.
          if (refundResult is RefundSuccess && ref.read(pagePrintProvider) == PagePrintType.single) {
            await ref.read(cardCountProvider.notifier).increase();
          }
        } catch (refundError) {
          logger.e('Payment and refund failed', error: refundError);
          refundResult = RefundFailure(LocaleKeys.alert_txt_refund_failed);
        }
        state = AsyncValue.error(PostPaymentRefundException(refundResult, e), stack);
        return;
      }
      state = AsyncValue.error(e, stack);
    }
  }
}
