import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:flutter_snaptag_kiosk/presentation/kiosk_shell/kiosk_info_service.dart';
import 'package:flutter_snaptag_kiosk/domain/repositories/i_payment_history_repository.dart';

class RefundOrderUseCase {
  final Ref _ref;
  final IPaymentHistoryRepository _repository;

  RefundOrderUseCase(this._ref, this._repository);

  Future<PaymentResponse?> execute(OrderEntity order) async {
    if (order.paymentAuthNumber == null) throw Exception('No payment auth number');
    if (order.completedAt == null) throw Exception('No completed date');

    final invoice = Invoice.calculate(order.amount.toInt());
    final response = await _ref.read(paymentRepositoryProvider).cancel(
          totalAmount: invoice.total,
          originalApprovalNo: order.paymentAuthNumber ?? '',
          originalApprovalDate: DateFormat('yyMMdd').format(order.completedAt!),
        );

    SlackLogService().sendLogToSlack('[SET UP] refund response: $response');
    await _updateOrderStatus(order, response);
    return response;
  }

  Future<void> _updateOrderStatus(OrderEntity order, PaymentResponse? payment) async {
    final kioskEventId = _ref.read(kioskInfoServiceProvider)?.kioskEventId;
    if (kioskEventId == null) throw Exception('No kiosk event id');

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
      await _repository.updateOrderStatus(
        order.orderId.toInt(),
        request.copyWith(status: OrderStatus.refunded_failed, description: '기취소된 거래'),
      );
      SlackLogService().sendPaymentBroadcastLogToSlak(
        InfoKey.paymentRefundFail.key,
        paymentDescription:
            '동작로직: 관리자 환불\n- 사유: 기취소된 거래\n- 인증번호: ${order.photoAuthNumber}\n- 승인번호: ${order.paymentAuthNumber ?? "없음"}',
      );
      return;
    }

    switch (payment?.res) {
      case '0000':
        await _repository.updateOrderStatus(order.orderId.toInt(), request);
      case '1000':
        await _repository.updateOrderStatus(order.orderId.toInt(), request.copyWith(description: '고객취소'));
        SlackLogService().sendPaymentBroadcastLogToSlak(
          InfoKey.paymentRefundFail.key,
          paymentDescription:
              '동작로직: 관리자 환불\n- 사유: 사용자가 환불취소 누름\n- 인증번호: ${order.photoAuthNumber}\n- 승인번호: ${order.paymentAuthNumber ?? "없음"}',
        );
      case '1004':
        await _repository.updateOrderStatus(order.orderId.toInt(), request.copyWith(description: '시간초과'));
        SlackLogService().sendPaymentBroadcastLogToSlak(
          InfoKey.paymentRefundFail.key,
          paymentDescription:
              '동작로직: 관리자 환불\n- 사유: 시간초과\n- 인증번호: ${order.photoAuthNumber}\n- 승인번호: ${order.paymentAuthNumber ?? "없음"}',
        );
      default:
        await _repository.updateOrderStatus(order.orderId.toInt(), request.copyWith(description: '확인필요'));
        SlackLogService().sendPaymentBroadcastLogToSlak(
          InfoKey.paymentRefundFail.key,
          paymentDescription:
              '동작로직: 관리자 환불\n- 사유: 확인필요\n- 인증번호: ${order.photoAuthNumber}\n- 승인번호: ${order.paymentAuthNumber ?? "없음"}',
        );
    }
  }
}
