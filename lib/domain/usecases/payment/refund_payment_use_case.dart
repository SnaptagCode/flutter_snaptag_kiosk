import 'package:flutter_snaptag_kiosk/domain/services/i_slack_log_service.dart';
import 'package:flutter_snaptag_kiosk/domain/services/order_update_service.dart';
import 'package:flutter_snaptag_kiosk/domain/usecases/payment/cancel_payment_use_case.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';

class RefundPaymentParams {
  final int orderId;
  final int kioskEventId;
  final int kioskMachineId;
  final int photoCardPrice;
  final String photoAuthNumber;
  final String approvalNo;
  final String? tradeTime;

  const RefundPaymentParams({
    required this.orderId,
    required this.kioskEventId,
    required this.kioskMachineId,
    required this.photoCardPrice,
    required this.photoAuthNumber,
    required this.approvalNo,
    this.tradeTime,
  });
}

class RefundPaymentUseCase {
  final CancelPaymentUseCase _cancelPayment;
  final OrderUpdateService _orderUpdate;
  final ISlackLogService _slackLog;

  const RefundPaymentUseCase(this._cancelPayment, this._orderUpdate, this._slackLog);

  Future<void> call(RefundPaymentParams params) async {
    if (params.approvalNo.trim().isEmpty) {
      throw Exception('No approval number available');
    }

    PaymentResponse? cancelResponse;
    try {
      cancelResponse = await _cancelPayment.call(
        totalAmount: params.photoCardPrice,
        originalApprovalNo: params.approvalNo,
        originalApprovalDate: params.tradeTime?.substring(0, 6) ?? '',
      );
      logger.i(
          'respCode: ${cancelResponse.respCode}\tORDER STATUS: ${cancelResponse.orderState}');
    } catch (e) {
      logger.e('Refund failed', error: e);
      rethrow;
    } finally {
      await _updateRefundOrder(params, cancelResponse);
    }
  }

  Future<void> _updateRefundOrder(RefundPaymentParams params, PaymentResponse? cancelResponse) async {
    if (cancelResponse?.orderState == OrderStatus.refunded) {
      await _orderUpdate.updateOrder(UpdateOrderParams(
        kioskEventId: params.kioskEventId,
        kioskMachineId: params.kioskMachineId,
        photoCardPrice: params.photoCardPrice,
        photoAuthNumber: params.photoAuthNumber,
        approval: cancelResponse,
        orderId: params.orderId,
        isRefund: true,
        description: '자동환불',
      ));
      _slackLog.sendPaymentBroadcastLog(
        InfoKey.paymentRefund.key,
        paymentDescription:
            '동작로직: 자동환불\n- 인증번호: ${params.photoAuthNumber}\n- 승인번호: ${params.approvalNo}',
      );
    } else {
      final description = _refundFailDescription(cancelResponse?.res);
      await _orderUpdate.updateOrder(UpdateOrderParams(
        kioskEventId: params.kioskEventId,
        kioskMachineId: params.kioskMachineId,
        photoCardPrice: params.photoCardPrice,
        photoAuthNumber: params.photoAuthNumber,
        approval: cancelResponse,
        orderId: params.orderId,
        isRefund: true,
        description: description,
      ));
      _slackLog.sendPaymentBroadcastLog(
        InfoKey.paymentRefundFail.key,
        paymentDescription:
            '동작로직: 자동환불\n- 사유: $description\n- 인증번호: ${params.photoAuthNumber}\n- 승인번호: ${cancelResponse?.approvalNo ?? params.approvalNo}',
      );
    }
  }

  String _refundFailDescription(String? res) => switch (res) {
        '1000' => '고객취소',
        '1004' => '시간초과',
        _ => '확인필요',
      };
}
