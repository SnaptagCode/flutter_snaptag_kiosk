import 'package:flutter_snaptag_kiosk/data/models/request/update_back_photo_request.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_snaptag_kiosk/features/move_me/providers/payment_failure_provider.dart';

part 'payment_service.g.dart';

@riverpod
class PaymentService extends _$PaymentService {
  @override
  FutureOr<void> build() => null;

  Future<void> processPayment() async {
    try {
      // 1. 사전 검증
      final settings = ref.read(kioskInfoServiceProvider);
      final backPhoto = ref.watch(verifyPhotoCardProvider).value;

      if (settings == null) {
        throw Exception('No kiosk settings available');
      }
      if (backPhoto == null) {
        throw Exception('No back photo available');
      }

      // 2. 주문 생성
      final orderResponse = await _createOrder();
      ref.read(createOrderInfoProvider.notifier).update(orderResponse);

      // 3. 결제 승인
      final price = ref.read(kioskInfoServiceProvider)!.photoCardPrice;
      final paymentResponse = await ref.read(paymentRepositoryProvider).approve(
            totalAmount: price,
          );
      ref.read(paymentResponseStateProvider.notifier).update(paymentResponse);
      final approvalNo = paymentResponse.approvalNo ?? '';
      final machineId = ref.read(kioskInfoServiceProvider)!.kioskMachineId;
      if (approvalNo.trim().isEmpty && paymentResponse.res == '0000') {
        SlackLogService().sendErrorLogToSlack('machineId: $machineId, Null approvalNo Card');
        final BackPhotoStatusResponse response = await ref.read(kioskRepositoryProvider).updateBackPhotoStatus(UpdateBackPhotoRequest(
          photoAuthNumber : backPhoto.photoAuthNumber,
          status : "STARTED",
        ));
        print("update status response : $response");
        ref.read(paymentFailureProvider.notifier).triggerFailure();
        final failResponse = await _updateFailOrder();
        ref.read(updateOrderInfoProvider.notifier).update(failResponse);
      } else {
        final response = await _updateOrder();
        ref.read(updateOrderInfoProvider.notifier).update(response);
        if (paymentResponse.res == '0000') {
          ref.read(cardCountProvider.notifier).decrease();
        }
      }
    } catch (e) {
      final response = await _updateOrder();
      ref.read(updateOrderInfoProvider.notifier).update(response);
      logger.e('Payment process failed', error: e);
      rethrow;
    } finally {
      // final response = await _updateOrder();
      // ref.read(updateOrderInfoProvider.notifier).update(response);
    }
  }

  Future<void> refund() async {
    try {
      final approvalInfo = ref.read(paymentResponseStateProvider);
      if (approvalInfo == null) {
        throw Exception('No payment approval info available');
      }
      final approvalNo = approvalInfo.approvalNo ?? '';
      if (approvalNo.trim().isEmpty) {
        throw Exception('No approval number available');
      }

      final price = ref.read(kioskInfoServiceProvider)!.photoCardPrice;
      final paymentResponse = await ref.read(paymentRepositoryProvider).cancel(
            totalAmount: price,
            originalApprovalNo: approvalInfo.approvalNo ?? '',
            originalApprovalDate: approvalInfo.tradeTime?.substring(0, 6) ?? '',
          );
      logger.i(
          'respCode: ${approvalInfo.respCode} \trespCode: ${approvalInfo.respCode} \nORDER STATUS: ${approvalInfo.orderState}');
      ref.read(paymentResponseStateProvider.notifier).update(paymentResponse);
    } catch (e) {
      logger.e('Refund failed', error: e);
      rethrow;
    } finally {
      await _updateOrder();
    }
  }

  Future<CreateOrderResponse> _createOrder() async {
    final settings = ref.read(kioskInfoServiceProvider);
    final backPhoto = ref.watch(verifyPhotoCardProvider).value;
    final isSingleSided = ref.read(pagePrintProvider) == PagePrintType.single;

    final request = CreateOrderRequest(
      kioskEventId: settings!.kioskEventId,
      kioskMachineId: settings.kioskMachineId,
      photoAuthNumber: backPhoto?.photoAuthNumber ?? '',
      amount: settings.photoCardPrice,
      paymentType: PaymentType.card,
      isSingleSided: isSingleSided,
    );

    return await ref.read(kioskRepositoryProvider).createOrderStatus(request);
  }

  Future<UpdateOrderResponse> _updateOrder() async {
    try {
      final settings = ref.read(kioskInfoServiceProvider);
      final backPhoto = ref.watch(verifyPhotoCardProvider).value;
      final approval = ref.watch(paymentResponseStateProvider);
      final orderId = ref.watch(createOrderInfoProvider)?.orderId;
      if (orderId == null) {
        throw Exception('No order id available');
      }
      logger.i(
          'respCode: ${approval?.respCode} \trespCode: ${approval?.respCode} \nORDER STATUS: ${approval?.orderState}');
      final request = UpdateOrderRequest(
        kioskEventId: settings!.kioskEventId,
        kioskMachineId: settings.kioskMachineId,
        photoAuthNumber: backPhoto?.photoAuthNumber ?? '-',
        amount: settings.photoCardPrice,
        status: approval?.orderState ?? OrderStatus.failed,
        approvalNumber: approval?.approvalNo ?? '-',
        purchaseAuthNumber: approval?.approvalNo ?? '-',
        authSeqNumber: approval?.approvalNo ?? '-',
        detail: approval?.KSNET ?? '{}',
      );

      return await ref.read(kioskRepositoryProvider).updateOrderStatus(orderId.toInt(), request);
    } catch (e) {
      rethrow;
    }
  }

  Future<UpdateOrderResponse> _updateFailOrder() async {
    try {
      final settings = ref.read(kioskInfoServiceProvider);
      final backPhoto = ref.watch(verifyPhotoCardProvider).value;
      final approval = ref.watch(paymentResponseStateProvider);
      final orderId = ref.watch(createOrderInfoProvider)?.orderId;
      if (orderId == null) {
        throw Exception('No order id available');
      }
      logger.i(
          'respCode: ${approval?.respCode} \trespCode: ${approval?.respCode} \nORDER STATUS: ${approval?.orderState}');
      final request = UpdateOrderRequest(
        kioskEventId: settings!.kioskEventId,
        kioskMachineId: settings.kioskMachineId,
        photoAuthNumber: backPhoto?.photoAuthNumber ?? '-',
        amount: settings.photoCardPrice,
        status: OrderStatus.failed,
        approvalNumber: '-',
        purchaseAuthNumber: '-',
        authSeqNumber: '-',
        detail: approval?.KSNET ?? '{}',
      );

      return await ref.read(kioskRepositoryProvider).updateOrderStatus(orderId.toInt(), request);
    } catch (e) {
      rethrow;
    }
  }
}
