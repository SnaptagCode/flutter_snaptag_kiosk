import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:flutter_snaptag_kiosk/presentation/core/card_count_provider.dart';
import 'package:flutter_snaptag_kiosk/presentation/home/notifier/home_back_photo_type_notifier.dart';
import 'package:flutter_snaptag_kiosk/presentation/kiosk_shell/home_timeout_provider.dart';
import 'package:flutter_snaptag_kiosk/presentation/kiosk_shell/kiosk_info_service.dart';
import 'package:flutter_snaptag_kiosk/presentation/payment/notifier/payment_action.dart';
import 'package:flutter_snaptag_kiosk/presentation/payment/notifier/payment_state.dart';
import 'package:flutter_snaptag_kiosk/domain/failures/payment_failure.dart';
import 'package:flutter_snaptag_kiosk/presentation/payment/di/payment_di.dart';
import 'package:flutter_snaptag_kiosk/domain/usecases/payment/process_payment_use_case.dart';
import 'package:flutter_snaptag_kiosk/domain/usecases/payment/refund_payment_use_case.dart';
import 'package:flutter_snaptag_kiosk/presentation/setup/main/notifiers/page_print_notifier.dart';
import 'package:flutter_snaptag_kiosk/domain/models/verification/back_photo_card.dart';
import 'package:flutter_snaptag_kiosk/presentation/core/back_photo_session_notifier.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'payment_notifier.g.dart';

@riverpod
class PaymentNotifier extends _$PaymentNotifier {
  late final ProcessPaymentUseCase _processPaymentUseCase;
  late final RefundPaymentUseCase _refundPaymentUseCase;

  @override
  PaymentState build() {
    _processPaymentUseCase = ref.watch(processPaymentUseCaseProvider);
    _refundPaymentUseCase = ref.watch(refundPaymentUseCaseProvider);
    return const PaymentState.initial();
  }

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

    // 나중에 catch 블록에서 환불 params 빌드에 사용
    int? kioskEventId;
    int? kioskMachineId;
    int? photoCardPrice;
    String? photoAuthNumber;
    bool isSingleSided = false;

    try {
      // TODO: 프린터 없이 디버깅 시 주석 해제
      // try {
      //   await ref.read(printerServiceProvider.notifier).checkFeeder();
      // } catch (e, stack) {
      //   state = PaymentState.failure(e, stack);
      //   return;
      // }

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

      final kioskInfo = ref.read(kioskInfoServiceProvider);
      final backPhoto = ref.read(backPhotoSessionProvider).value;
      isSingleSided = ref.read(pagePrintProvider) == PagePrintType.single;

      if (kioskInfo == null) throw PreconditionFailedException('No kiosk settings available');
      if (backPhoto == null) throw PreconditionFailedException('No back photo available');

      kioskEventId = kioskInfo.kioskEventId;
      kioskMachineId = kioskInfo.kioskMachineId;
      photoCardPrice = kioskInfo.photoCardPrice;
      photoAuthNumber = backPhoto.photoAuthNumber;

      await _processPaymentUseCase.call(ProcessPaymentParams(
        kioskEventId: kioskEventId,
        kioskMachineId: kioskMachineId,
        photoCardPrice: photoCardPrice,
        photoAuthNumber: photoAuthNumber,
        isSingleSided: isSingleSided,
      ));

      await ref.read(cardCountProvider.notifier).decrease();
      state = const PaymentState.success();
    } catch (e, stack) {
      if (e is PaymentRefundableException && kioskEventId != null) {
        try {
          await _refundPaymentUseCase.call(RefundPaymentParams(
            orderId: e.orderId,
            kioskEventId: kioskEventId,
            kioskMachineId: kioskMachineId!,
            photoCardPrice: photoCardPrice!,
            photoAuthNumber: photoAuthNumber!,
            approvalNo: e.approvalNo,
            tradeTime: e.tradeTime,
          ));
          if (isSingleSided) {
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
