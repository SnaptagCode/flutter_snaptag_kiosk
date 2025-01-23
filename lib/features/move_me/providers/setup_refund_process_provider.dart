import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'setup_refund_process_provider.g.dart';

@riverpod
class SetupRefundProcess extends _$SetupRefundProcess {
  @override
  FutureOr<void> build() {
    return null;
  }

  Future<void> startRefund(OrderEntity order) async {
    state = const AsyncLoading();
    if (order.paymentAuthNumber == null) {
      throw Exception('No payment auth number available');
    }
    if (order.completedAt == null) {
      throw Exception('No completed date available');
    }
    await AsyncValue.guard(() async {
      final Invoice invoice = Invoice.calculate(order.amount.toInt());
      PaymentResponse response = await ref.read(paymentRepositoryProvider).cancel(
          totalAmount: invoice.total,
          originalApprovalNo: order.paymentAuthNumber ?? '',
          originalApprovalDate: DateFormat('yyMMdd').format(order.completedAt!));

      await _updateOrderStatus(OrderStatus.refunded, order, response);
    });

    if (state.hasError) {
      /**
       await updateOrder(
        OrderStatus.refunded_failed,
        order,
      );
       */
    }
  }

  Future<void> _updateOrderStatus(OrderStatus status, OrderEntity order, PaymentResponse payment) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final kioskEventId = ref.watch(storageServiceProvider).settings.kioskEventId;
      final request = UpdateOrderRequest(
        kioskEventId: kioskEventId,
        kioskMachineId: order.kioskMachineId,
        photoAuthNumber: order.photoAuthNumber,
        amount: order.amount.toInt(),
        status: status,
        approvalNumber: payment.approvalNo ?? '',
        purchaseAuthNumber: payment.approvalNo ?? '',
        uniqueNumber: payment.approvalNo ?? '',
        authSeqNumber: payment.tradeUniqueNo ?? '',
        tradeNumber: payment.tradeUniqueNo ?? '',
        detail: payment.toJson().toString(),
      );
      final orderId = ref.watch(createOrderInfoProvider)?.orderId;
      if (orderId == null) {
        throw Exception('No order id available');
      }
      await ref.read(kioskRepositoryProvider).updateOrderStatus(orderId.toInt(), request);
    });
  }
}
