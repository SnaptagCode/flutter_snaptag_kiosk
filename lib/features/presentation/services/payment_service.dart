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

      try {
        // 3. 결제 승인
        final paymentResponse = await _approvePayment(ref.read(storageServiceProvider).settings.photoCardPrice);

        if (!paymentResponse.isSuccess) {
          throw Exception('Payment failed: ${paymentResponse.errorMessage} (${paymentResponse.res})');
        }
        ref.read(paymentResponseStateProvider.notifier).update(paymentResponse);

        // 4. 주문 상태 업데이트
        final response = await _updateOrder(OrderStatus.completed);

        // 5. 프린트 정보 업데이트 (completed 상태일 때만)
        if (response.status == OrderStatus.completed) {
          ref.read(backPhotoForPrintInfoProvider.notifier).update(response.backPhotoForPrint);
        }
      } catch (e) {
        await _updateOrder(OrderStatus.failed);
        rethrow;
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
        throw Exception('No payment approval info available');
      }

      await ref.read(paymentRepositoryProvider).cancel(
            totalAmount: ref.read(storageServiceProvider).settings.photoCardPrice,
            originalApprovalNo: approvalInfo.approvalNo ?? '',
            originalApprovalDate: approvalInfo.tradeTime?.substring(0, 6) ?? '',
          );

      await _updateOrder(OrderStatus.refunded);
    } catch (e) {
      logger.e('Refund failed', error: e);
      await _updateOrder(OrderStatus.refunded_failed);
      rethrow;
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

  Future<PaymentResponse> _approvePayment(int total) async {
    try {
      final Invoice invoice = Invoice.calculate(total);
      return await ref.read(paymentRepositoryProvider).approve(
            totalAmount: invoice.total,
          );
    } catch (e) {
      rethrow;
    }
  }

  Future<UpdateOrderResponse> _updateOrder(OrderStatus status) async {
    try {
      final settings = ref.watch(storageServiceProvider).settings;
      final backPhoto = ref.watch(verifyPhotoCardProvider).value;
      final approval = ref.watch(paymentResponseStateProvider);

      final request = UpdateOrderRequest(
        kioskEventId: settings.kioskEventId,
        kioskMachineId: settings.kioskMachineId,
        photoAuthNumber: backPhoto?.photoAuthNumber ?? '',
        amount: settings.photoCardPrice,
        status: status,
        approvalNumber: approval?.approvalNo ?? '',
        purchaseAuthNumber: approval?.approvalNo ?? '',
        uniqueNumber: approval?.approvalNo ?? '',
        authSeqNumber: approval?.tradeUniqueNo ?? '',
        tradeNumber: approval?.tradeUniqueNo ?? '',
        detail: approval?.toJson().toString() ?? '',
      );

      final orderId = ref.watch(createOrderInfoProvider)?.orderId;
      if (orderId == null) {
        throw Exception('No order id available');
      }

      return await ref.read(kioskRepositoryProvider).updateOrderStatus(orderId.toInt(), request);
    } catch (e) {
      throw Exception('주문 업데이트 실패');
    }
  }
}
