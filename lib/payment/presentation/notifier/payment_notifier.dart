import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:flutter_snaptag_kiosk/presentation/core/card_count_provider.dart';
import 'package:flutter_snaptag_kiosk/home/presentation/notifier/home_back_photo_type_notifier.dart';
import 'package:flutter_snaptag_kiosk/presentation/kiosk_shell/home_timeout_provider.dart';
import 'package:flutter_snaptag_kiosk/presentation/kiosk_shell/kiosk_info_service.dart';
import 'package:flutter_snaptag_kiosk/payment/presentation/notifier/payment_action.dart';
import 'package:flutter_snaptag_kiosk/payment/presentation/notifier/payment_state.dart';
import 'package:flutter_snaptag_kiosk/payment/domain/failure/payment_failure.dart';
import 'package:flutter_snaptag_kiosk/payment/presentation/notifier/payment_service.dart';
import 'package:flutter_snaptag_kiosk/presentation/setup/main/notifiers/page_print_notifier.dart';
import 'package:flutter_snaptag_kiosk/domain/models/verification/back_photo_card.dart';
import 'package:flutter_snaptag_kiosk/presentation/core/back_photo_session_notifier.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'payment_notifier.g.dart';

@riverpod
class PaymentNotifier extends _$PaymentNotifier {
  @override
  PaymentState build() => const PaymentState.initial();

  Future<void> onAction(PaymentAction action) async {
    switch (action) {
      case PaymentActionPay():
        await _pay();
      case PaymentActionReset():
        _reset();
      case PaymentActionSelectFixed() || PaymentActionRefreshBackPhoto():
        break;
    }
  }

  Future<void> _pay() async {
    if (state is PaymentStateLoading) return;

    state = const PaymentState.loading();

    // TODO: 프린터 없이 디버깅 시 주석 해제
    // // 결제 전 카드 피더 체크
    // try {
    //   await ref.read(printerServiceProvider.notifier).checkFeeder();
    // } catch (e, stack) {
    //   state = PaymentState.failure(e, stack);
    //   return;
    // }

    try {
      final selection = ref.read(backPhotoTypeNotifierProvider);

      if (selection?.type == BackPhotoType.fixed && selection?.fixedIndex != null) {
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
          ref.read(backPhotoSessionProvider.notifier).updateState(BackPhotoCard(
                kioskEventId: kiosk.kioskEventId,
                backPhotoCardId: response.backPhotoCardId,
                backPhotoCardOriginUrl: selectedCard.originUrl,
                photoAuthNumber: response.photoAuthNumber,
                formattedBackPhotoCardUrl: response.formattedBackPhotoCardUrl,
              ));
        }
      }

      ref.read(homeTimeoutNotifierProvider.notifier).cancelTimerWithCallback();

      await ref.read(paymentServiceProvider.notifier).processPayment();

      state = const PaymentState.success();
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
      state = PaymentState.failure(e, stack);
    }
  }

  void _reset() => state = const PaymentState.initial();
}
