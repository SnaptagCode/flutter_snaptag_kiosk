import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'setup_refund_process_provider.g.dart';

@riverpod
class SetupRefundProcess extends _$SetupRefundProcess {
  @override
  FutureOr<PaymentResponse?> build() {
    return null;
  }

  Future<void> startRefund(OrderEntity order) async {
    if (order.paymentAuthNumber == null) {
      throw Exception('No payment auth number available');
    }
    if (order.completedAt == null) {
      throw Exception('No completed date available');
    }

    try {
      final Invoice invoice = Invoice.calculate(order.amount.toInt());
      state = const AsyncValue.loading();

      final response = await ref.read(paymentRepositoryProvider).cancel(
            totalAmount: invoice.total,
            originalApprovalNo: order.paymentAuthNumber ?? '',
            originalApprovalDate: DateFormat('yyMMdd').format(order.completedAt!),
          );

      // 응답을 상태로 저장
      state = AsyncValue.data(response);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    } finally {
      await _updateOrderStatus(order);
    }
  }

  Future<void> _updateOrderStatus(OrderEntity order) async {
    late UpdateOrderRequest request;
    try {
      final payment = state.value;

      final kioskEventId = ref.watch(storageServiceProvider).settings.kioskEventId;

      request = UpdateOrderRequest(
        kioskEventId: kioskEventId,
        kioskMachineId: order.kioskMachineId,
        photoAuthNumber: order.photoAuthNumber,
        amount: order.amount.toInt(),
        status: payment?.orderState ?? OrderStatus.refunded_failed,
        approvalNumber: order.paymentAuthNumber ?? '',
        purchaseAuthNumber: order.paymentAuthNumber ?? '',
        authSeqNumber: order.paymentAuthNumber ?? '',
        detail: payment?.KSNET.toString() ?? '{}',
      );
    } catch (e) {
      rethrow;
    } finally {
      /// 이미 취소된 거래
      if (state.value?.respCode == '7001') {
        await ref.read(kioskRepositoryProvider).updateOrderStatus(
              order.orderId.toInt(),
              request.copyWith(status: OrderStatus.refunded),
            );
      }
      await ref.read(kioskRepositoryProvider).updateOrderStatus(
            order.orderId.toInt(),
            request,
          );
    }
  }
}
