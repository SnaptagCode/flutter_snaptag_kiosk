import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'payment_service.g.dart';

@riverpod
class PaymentService extends _$PaymentService {
  @override
  FutureOr<void> build() => null;

  // UseCase를 read()하여 주입
  late final PaymentUseCase _paymentUseCase = PaymentUseCase(ref: ref);

  /// 기존 processPayment() -> UseCase 호출
  Future<void> processPayment() async {
    try {
      final settings = ref.read(kioskInfoServiceProvider);
      final backPhoto = ref.watch(verifyPhotoCardProvider).value;

      if (settings == null || backPhoto == null) {
        throw Exception('No kiosk settings or back photo');
      }
      final amount = settings.photoCardPrice;

      // UseCase 호출
      final result = await _paymentUseCase.processPayment(
        kioskEventId: settings.kioskEventId,
        kioskMachineId: settings.kioskMachineId,
        photoAuthNumber: backPhoto.photoAuthNumber,
        amount: amount,
      );

      // 1) PaymentResponse를 스테이트에 반영 (ex: UI에서 결제승인 정보 활용)
      ref.read(paymentResponseStateProvider.notifier).update(result.$1);
      // 2) UpdateOrderResponse를 통해 backPhotoForPrint가 있으면 저장
      ref.read(updateOrderInfoProvider.notifier).update(result.$2);

      if (result.$2.status == OrderStatus.completed && result.$2.backPhotoForPrint != null) {
        ref.read(backPhotoForPrintInfoProvider.notifier).update(result.$2.backPhotoForPrint!);
      }
    } catch (e) {
      logger.e('Payment process failed', error: e);
      rethrow;
    }
  }

  Future<void> refund() async {
    try {
      final approvalInfo = ref.read(paymentResponseStateProvider);
      if (approvalInfo == null) {
        throw Exception('No payment approval info');
      }
      final settings = ref.read(kioskInfoServiceProvider);
      final orderId = ref.read(createOrderInfoProvider)?.orderId;
      if (settings == null || orderId == null) {
        throw Exception('No kiosk settings or order info');
      }

      final response = await _paymentUseCase.refundPayment(
        kioskEventId: settings.kioskEventId,
        kioskMachineId: settings.kioskMachineId,
        amount: settings.photoCardPrice,
        originalApprovalNo: approvalInfo.approvalNo ?? '',
        originalApprovalDate: approvalInfo.tradeTime?.substring(0, 6) ?? '',
        orderId: orderId.toInt(),
      );

      ref.read(paymentResponseStateProvider.notifier).update(response);
    } catch (e) {
      logger.e('Refund failed', error: e);
      rethrow;
    }
  }
}
