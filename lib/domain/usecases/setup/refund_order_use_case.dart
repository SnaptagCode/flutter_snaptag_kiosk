import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_snaptag_kiosk/core/core.dart';
import 'package:flutter_snaptag_kiosk/domain/models/enums/order_status.dart';
import 'package:flutter_snaptag_kiosk/domain/models/invoice.dart';
import 'package:flutter_snaptag_kiosk/domain/models/order/order_data.dart';
import 'package:flutter_snaptag_kiosk/domain/models/order/update_order_params.dart';
import 'package:flutter_snaptag_kiosk/domain/models/payment/payment_result.dart';
import 'package:flutter_snaptag_kiosk/domain/repositories/i_payment_history_repository.dart';
import 'package:flutter_snaptag_kiosk/domain/repositories/i_payment_repository.dart';
import 'package:flutter_snaptag_kiosk/domain/services/i_slack_log_service.dart';

class RefundOrderUseCase {
  final IPaymentHistoryRepository _repository;
  final IPaymentRepository _paymentRepository;
  final ISlackLogService _slackLog;
  final String? _cardTerminalId;

  RefundOrderUseCase(
    this._repository,
    this._paymentRepository,
    this._slackLog, {
    required String? cardTerminalId,
  }) : _cardTerminalId = cardTerminalId;

  Future<PaymentResult?> call(OrderData order, {required int kioskEventId}) async {
    if (order.paymentAuthNumber == null) throw Exception('No payment auth number');
    if (order.completedAt == null) throw Exception('No completed date');

    final invoice = Invoice.calculate(order.amount.toInt());
    final response = await _paymentRepository.cancel(
      kioskMachineId: order.kioskMachineId,
      cardTerminalId: _cardTerminalId,
      totalAmount: invoice.total,
      originalApprovalNo: order.paymentAuthNumber ?? '',
      originalApprovalDate: DateFormat('yyMMdd').format(order.completedAt!),
    );

    _slackLog.sendLog('[SET UP] refund response: $response');
    await _updateOrderStatus(order, response, kioskEventId: kioskEventId);
    return response;
  }

  Future<void> _updateOrderStatus(
    OrderData order,
    PaymentResult? payment, {
    required int kioskEventId,
  }) async {
    final params = UpdateHistoryOrderParams(
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

    if (payment?.isAlreadyCanceled == true) {
      await _repository.updateOrderStatus(
        order.orderId.toInt(),
        params.copyWith(status: OrderStatus.refunded_failed, description: '기취소된 거래'),
      );
      _slackLog.sendPaymentBroadcastLog(
        InfoKey.paymentRefundFail.key,
        paymentDescription:
            '동작로직: 관리자 환불\n- 사유: 기취소된 거래\n- 인증번호: ${order.photoAuthNumber}\n- 승인번호: ${order.paymentAuthNumber ?? "없음"}',
      );
      return;
    }

    switch (payment?.res) {
      case '0000':
        await _repository.updateOrderStatus(order.orderId.toInt(), params);
      case '1000':
        await _repository.updateOrderStatus(order.orderId.toInt(), params.copyWith(description: '고객취소'));
        _slackLog.sendPaymentBroadcastLog(
          InfoKey.paymentRefundFail.key,
          paymentDescription:
              '동작로직: 관리자 환불\n- 사유: 사용자가 환불취소 누름\n- 인증번호: ${order.photoAuthNumber}\n- 승인번호: ${order.paymentAuthNumber ?? "없음"}',
        );
      case '1004':
        await _repository.updateOrderStatus(order.orderId.toInt(), params.copyWith(description: '시간초과'));
        _slackLog.sendPaymentBroadcastLog(
          InfoKey.paymentRefundFail.key,
          paymentDescription:
              '동작로직: 관리자 환불\n- 사유: 시간초과\n- 인증번호: ${order.photoAuthNumber}\n- 승인번호: ${order.paymentAuthNumber ?? "없음"}',
        );
      default:
        await _repository.updateOrderStatus(order.orderId.toInt(), params.copyWith(description: '확인필요'));
        _slackLog.sendPaymentBroadcastLog(
          InfoKey.paymentRefundFail.key,
          paymentDescription:
              '동작로직: 관리자 환불\n- 사유: 확인필요\n- 인증번호: ${order.photoAuthNumber}\n- 승인번호: ${order.paymentAuthNumber ?? "없음"}',
        );
    }
  }
}
