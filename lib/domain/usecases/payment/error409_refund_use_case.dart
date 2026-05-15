import 'package:flutter_snaptag_kiosk/domain/models/verification/refund_order_info.dart';
import 'package:flutter_snaptag_kiosk/domain/services/i_slack_log_service.dart';
import 'package:flutter_snaptag_kiosk/domain/services/order_update_service.dart';
import 'package:flutter_snaptag_kiosk/domain/usecases/payment/cancel_payment_use_case.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:intl/intl.dart';

class Error409RefundParams {
  final RefundOrderInfo order;
  final int kioskEventId;
  final int kioskMachineId;
  final int photoCardPrice;
  final String photoAuthNumber;

  const Error409RefundParams({
    required this.order,
    required this.kioskEventId,
    required this.kioskMachineId,
    required this.photoCardPrice,
    required this.photoAuthNumber,
  });
}

class Error409RefundUseCase {
  final CancelPaymentUseCase _cancelPayment;
  final OrderUpdateService _orderUpdate;
  final ISlackLogService _slackLog;

  const Error409RefundUseCase(this._cancelPayment, this._orderUpdate, this._slackLog);

  Future<bool> call(Error409RefundParams params) async {
    final orderId = params.order.orderId;
    if (orderId == null) throw Exception('No order id available');

    final approvalNo = params.order.authSeqNumber ?? '';
    if (approvalNo.trim().isEmpty) {
      throw Exception('No approval number available');
    }

    bool isSuccess = false;
    PaymentResponse? cancelResponse;
    try {
      cancelResponse = await _cancelPayment.call(
        totalAmount: params.photoCardPrice,
        originalApprovalNo: approvalNo,
        originalApprovalDate: DateFormat('yyMMdd').format(params.order.completedAt!),
      );
      _slackLog.sendLog('error409_refund cancelResponse: $cancelResponse');
      isSuccess = cancelResponse.isSuccess;
    } catch (e) {
      _slackLog.sendLog('error409 refund fail error : $e');
      logger.e('Refund failed', error: e);
      rethrow;
    } finally {
      await _updateRefundOrder(params, orderId, cancelResponse);
    }

    return isSuccess;
  }

  Future<void> _updateRefundOrder(Error409RefundParams params, int orderId, PaymentResponse? cancelResponse) async {
    if (cancelResponse?.orderState == OrderStatus.refunded) {
      final response = await _orderUpdate.updateOrder(UpdateOrderParams(
        kioskEventId: params.kioskEventId,
        kioskMachineId: params.kioskMachineId,
        photoCardPrice: params.photoCardPrice,
        photoAuthNumber: params.photoAuthNumber,
        approval: cancelResponse,
        orderId: orderId,
        isRefund: true,
        description: '환불안내',
      ));
      _slackLog.sendLog('error409 response: $response');
      _slackLog.sendPaymentBroadcastLog(
        InfoKey.paymentRefund.key,
        paymentDescription:
            '동작로직: 환불안내\n- 인증번호: ${params.photoAuthNumber}\n- 승인번호: ${params.order.authSeqNumber ?? "없음"}',
      );
    } else {
      final (description, paymentDesc) = switch (cancelResponse?.res) {
        '1000' => (
            '고객취소',
            '동작로직: 환불안내\n- 사유: 사용자가 환불취소 누름\n- 인증번호: ${params.photoAuthNumber}\n- 승인번호: ${cancelResponse?.approvalNo ?? "없음"}'
          ),
        '1004' => (
            '시간초과',
            '동작로직: 환불안내\n- 사유: 시간초과\n- 인증번호: ${params.photoAuthNumber}\n- 승인번호: ${cancelResponse?.approvalNo ?? "없음"}'
          ),
        _ => (
            '확인필요',
            '동작로직: 환불안내\n- 사유: 확인필요\n- 인증번호: ${params.photoAuthNumber}\n- 승인번호: ${cancelResponse?.approvalNo ?? "없음"}'
          ),
      };
      await _orderUpdate.updateOrder(UpdateOrderParams(
        kioskEventId: params.kioskEventId,
        kioskMachineId: params.kioskMachineId,
        photoCardPrice: params.photoCardPrice,
        photoAuthNumber: params.photoAuthNumber,
        approval: cancelResponse,
        orderId: orderId,
        isRefund: true,
        description: description,
      ));
      _slackLog.sendPaymentBroadcastLog(InfoKey.paymentRefundFail.key, paymentDescription: paymentDesc);
    }
  }
}
