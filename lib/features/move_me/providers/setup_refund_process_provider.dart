import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'setup_refund_process_provider.g.dart';

@riverpod
class SetupRefundProcess extends _$SetupRefundProcess {
  @override
  FutureOr<PaymentResponse?> build() => null;

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

      state = AsyncValue.data(response);
      await _updateOrderStatus(order);

      // 현재 페이지 정보를 가져와서 동일한 페이지로 새로고침
      final currentPage = ref.read(ordersPageProvider()).requireValue.paging.currentPage;
      ref.read(ordersPageProvider().notifier).goToPage(currentPage);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> _updateOrderStatus(OrderEntity order) async {
    final payment = state.value;
    final kioskEventId = ref.read(kioskInfoServiceProvider.notifier).settings.kioskEventId;

    final request = UpdateOrderRequest(
      kioskEventId: kioskEventId,
      kioskMachineId: order.kioskMachineId,
      photoAuthNumber: order.photoAuthNumber,
      amount: order.amount.toInt(),
      status: payment?.orderState ?? OrderStatus.refunded_failed,
      approvalNumber: order.paymentAuthNumber ?? '',
      purchaseAuthNumber: order.paymentAuthNumber ?? '',
      authSeqNumber: order.paymentAuthNumber ?? '',
      detail: payment?.KSNET ?? '{}',
    );

    if (payment?.respCode == '7001') {
      // 이미 취소된 거래
      await ref.read(kioskRepositoryProvider).updateOrderStatus(
            order.orderId.toInt(),
            request.copyWith(status: OrderStatus.refunded),
          );
    } else {
      await ref.read(kioskRepositoryProvider).updateOrderStatus(
            order.orderId.toInt(),
            request,
          );
    }
  }
}
