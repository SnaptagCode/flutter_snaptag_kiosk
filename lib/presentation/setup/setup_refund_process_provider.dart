import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:flutter_snaptag_kiosk/presentation/kiosk_shell/kiosk_info_service.dart';
import 'package:flutter_snaptag_kiosk/presentation/setup/payment_history_provider.dart';
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
    final kioskEventId = ref.read(kioskInfoServiceProvider)?.kioskEventId;

    if (kioskEventId == null) {
      throw Exception('No kiosk event id available');
    }
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
            request.copyWith(status: OrderStatus.refunded_failed, description: "기취소된 거래"),
          );
      SlackLogService().sendPaymentBroadcastLogToSlak(InfoKey.paymentRefundFail.key,
          paymentDescription:
              "동작로직: 관리자 환불\n- 사유: 기취소된 거래\n- 인증번호: ${order.photoAuthNumber}\n- 승인번호: ${order.paymentAuthNumber ?? "없음"}");
    } else {
      switch (payment?.res) {
        case '0000':
          await ref.read(kioskRepositoryProvider).updateOrderStatus(
                order.orderId.toInt(),
                request,
              );
        case '1000':
          await ref.read(kioskRepositoryProvider).updateOrderStatus(
                order.orderId.toInt(),
                request.copyWith(description: "고객취소"),
              );
          SlackLogService().sendPaymentBroadcastLogToSlak(InfoKey.paymentRefundFail.key,
              paymentDescription:
                  "동작로직: 관리자 환불\n- 사유: 사용자가 환불취소 누름\n- 인증번호: ${order.photoAuthNumber}\n- 승인번호: ${order.paymentAuthNumber ?? "없음"}");
          break;
        case '1004':
          await ref.read(kioskRepositoryProvider).updateOrderStatus(
                order.orderId.toInt(),
                request.copyWith(description: "시간초과"),
              );
          SlackLogService().sendPaymentBroadcastLogToSlak(InfoKey.paymentRefundFail.key,
              paymentDescription:
                  "동작로직: 관리자 환불\n- 사유: 시간초과\n- 인증번호: ${order.photoAuthNumber}\n- 승인번호: ${order.paymentAuthNumber ?? "없음"}");
          break;
        default:
          await ref.read(kioskRepositoryProvider).updateOrderStatus(
                order.orderId.toInt(),
                request.copyWith(description: "확인필요"),
              );
          SlackLogService().sendPaymentBroadcastLogToSlak(InfoKey.paymentRefundFail.key,
              paymentDescription:
                  "동작로직: 관리자 환불\n- 사유: 확인필요\n- 인증번호: ${order.photoAuthNumber}\n- 승인번호: ${order.paymentAuthNumber ?? "없음"}");
      }
    }
  }
}
