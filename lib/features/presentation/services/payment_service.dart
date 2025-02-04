import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'payment_service.g.dart';

@riverpod
class PaymentService extends _$PaymentService {
  @override
  FutureOr<void> build() => null;

  Future<void> processPayment() async {
    try {
      // 1. 사전 검증
      _validatePaymentRequirements();

      // 2. 주문 생성
      final orderResponse = await _createOrder();
      ref.read(createOrderInfoProvider.notifier).update(orderResponse);

      // 3. 결제 승인

      final Invoice invoice = Invoice.calculate(ref.read(storageServiceProvider).settings.photoCardPrice);
      final paymentResponse = await ref.read(paymentRepositoryProvider).approve(
            totalAmount: invoice.total,
          );

      ref.read(paymentResponseStateProvider.notifier).update(paymentResponse);
    } catch (e) {
      logger.e('Payment process failed', error: e);
      rethrow;
    } finally {
      final response = await _updateOrder();
      // 5. 프린트 정보 업데이트 (completed 상태일 때만)
      if (response.status == OrderStatus.completed && response.backPhotoForPrint != null) {
        ref.read(backPhotoForPrintInfoProvider.notifier).update(response.backPhotoForPrint!);
      }
    }
  }

  Future<void> refund() async {
    try {
      final approvalInfo = ref.read(paymentResponseStateProvider);
      if (approvalInfo == null) {
        throw Exception('No payment approval info available');
      }

      await ref.read(paymentRepositoryProvider).cancel(
            totalAmount: ref.read(storageServiceProvider).settings.photoCardPrice,
            originalApprovalNo: approvalInfo.approvalNo ?? '',
            originalApprovalDate: approvalInfo.tradeTime?.substring(0, 6) ?? '',
          );
    } catch (e) {
      logger.e('Refund failed', error: e);
      rethrow;
    } finally {
      await _updateOrder();
    }
  }

  void _validatePaymentRequirements() {
    final settings = ref.watch(storageServiceProvider).settings;
    final backPhoto = ref.watch(verifyPhotoCardProvider).value;

    if (settings.kioskEventId == 0) {
      throw Exception(KioskErrorType.missingEventId);
    }
    if (settings.photoCardPrice <= 0) {
      throw Exception('Invalid photo card price');
    }
    if (backPhoto == null) {
      throw Exception('No back photo available');
    }
  }

  Future<CreateOrderResponse> _createOrder() async {
    final settings = ref.watch(storageServiceProvider).settings;
    final backPhoto = ref.watch(verifyPhotoCardProvider).value;

    final request = CreateOrderRequest(
      kioskEventId: settings.kioskEventId,
      kioskMachineId: settings.kioskMachineId,
      photoAuthNumber: backPhoto?.photoAuthNumber ?? '',
      amount: settings.photoCardPrice,
      paymentType: PaymentType.card,
    );

    return await ref.read(kioskRepositoryProvider).createOrderStatus(request);
  }

  Future<UpdateOrderResponse> _updateOrder() async {
    try {
      final settings = ref.watch(storageServiceProvider).settings;
      final backPhoto = ref.watch(verifyPhotoCardProvider).value;
      final approval = ref.watch(paymentResponseStateProvider);

      final request = UpdateOrderRequest(
        kioskEventId: settings.kioskEventId,
        kioskMachineId: settings.kioskMachineId,
        photoAuthNumber: backPhoto?.photoAuthNumber ?? '',
        amount: settings.photoCardPrice,
        status: approval?.orderState ?? OrderStatus.failed,
        approvalNumber: approval?.approvalNo ?? '',
        purchaseAuthNumber: approval?.approvalNo ?? '',
        uniqueNumber: approval?.approvalNo ?? '',
        authSeqNumber: approval?.tradeUniqueNo ?? '',
        tradeNumber: approval?.tradeUniqueNo ?? '',
        detail: approval?.KSNET.toString() ?? '{}',
      );

      final orderId = ref.watch(createOrderInfoProvider)?.orderId;
      if (orderId == null) {
        throw Exception('No order id available');
      }

      return await ref.read(kioskRepositoryProvider).updateOrderStatus(orderId.toInt(), request);
    } catch (e) {
      rethrow;
    }
  }
}
