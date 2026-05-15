import 'package:flutter_snaptag_kiosk/domain/failures/payment_failure.dart';
import 'package:flutter_snaptag_kiosk/domain/repositories/i_kiosk_repository.dart';
import 'package:flutter_snaptag_kiosk/domain/services/i_slack_log_service.dart';
import 'package:flutter_snaptag_kiosk/domain/services/order_update_service.dart';
import 'package:flutter_snaptag_kiosk/domain/usecases/payment/approve_payment_use_case.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';

class ProcessPaymentParams {
  final int kioskEventId;
  final int kioskMachineId;
  final int photoCardPrice;
  final String photoAuthNumber;
  final bool isSingleSided;

  const ProcessPaymentParams({
    required this.kioskEventId,
    required this.kioskMachineId,
    required this.photoCardPrice,
    required this.photoAuthNumber,
    required this.isSingleSided,
  });
}

class ProcessPaymentResult {
  final CreateOrderResponse orderResponse;
  final PaymentResponse paymentResponse;

  const ProcessPaymentResult({required this.orderResponse, required this.paymentResponse});
}

class ProcessPaymentUseCase {
  final IKioskRepository _repository;
  final ApprovePaymentUseCase _approvePayment;
  final OrderUpdateService _orderUpdate;
  final ISlackLogService _slackLog;

  const ProcessPaymentUseCase(this._repository, this._approvePayment, this._orderUpdate, this._slackLog);

  Future<ProcessPaymentResult> call(ProcessPaymentParams params) async {
    final orderResponse = await _createOrder(params)
        .catchError((e) => throw OrderCreationException('Create order fail: $e'));
    final orderId = orderResponse.orderId;

    try {
      final paymentResponse = await _approvePayment.call(totalAmount: params.photoCardPrice);
      _slackLog.sendLog('paymentResponse : $paymentResponse');
      await _handlePaymentResult(params, orderId, paymentResponse);
      // _handlePaymentResult 가 throw 없이 반환 = 결제 성공
      return ProcessPaymentResult(orderResponse: orderResponse, paymentResponse: paymentResponse);
    } catch (e) {
      if (e is PaymentRefundableException || e is PaymentFailedException) rethrow;
      await _orderUpdate.updateOrder(UpdateOrderParams(
        kioskEventId: params.kioskEventId,
        kioskMachineId: params.kioskMachineId,
        photoCardPrice: params.photoCardPrice,
        photoAuthNumber: params.photoAuthNumber,
        orderId: orderId,
        isRefund: false,
        description: '확인필요',
      ));
      throw PaymentRefundableException(
        '결제 처리 중 오류가 발생했습니다.',
        orderId: orderId,
        approvalNo: '',
        description: e.toString(),
      );
    }
  }

  Future<CreateOrderResponse> _createOrder(ProcessPaymentParams params) async {
    final request = CreateOrderRequest(
      kioskEventId: params.kioskEventId,
      kioskMachineId: params.kioskMachineId,
      photoAuthNumber: params.photoAuthNumber,
      amount: params.photoCardPrice,
      paymentType: PaymentType.card,
      isSingleSided: params.isSingleSided,
    );
    return await _repository.createOrderStatus(request);
  }

  Future<void> _handlePaymentResult(
    ProcessPaymentParams params,
    int orderId,
    PaymentResponse paymentResponse,
  ) async {
    final approvalNo = paymentResponse.approvalNo ?? '';
    if (approvalNo.trim().isEmpty && paymentResponse.res == '0000') {
      await _handleEmptyApprovalNumber(params, orderId, paymentResponse);
    } else {
      await _handlePaymentResponse(params, orderId, paymentResponse);
    }
  }

  Future<void> _handleEmptyApprovalNumber(
    ProcessPaymentParams params,
    int orderId,
    PaymentResponse paymentResponse,
  ) async {
    final description = _formatPaymentMessages(paymentResponse);
    await _orderUpdate.updateOrder(UpdateOrderParams(
      kioskEventId: params.kioskEventId,
      kioskMachineId: params.kioskMachineId,
      photoCardPrice: params.photoCardPrice,
      photoAuthNumber: params.photoAuthNumber,
      approval: paymentResponse,
      orderId: orderId,
      isRefund: false,
      description: description,
    ));
    _slackLog.sendPaymentBroadcastLog(
      InfoKey.paymentFail.key,
      paymentDescription:
          '사유: $description\n- 인증번호: ${params.photoAuthNumber}\n- 승인번호: ${paymentResponse.approvalNo ?? "없음"}',
    );
    throw EmptyApprovalNumberException(description: description);
  }

  Future<void> _handlePaymentResponse(
    ProcessPaymentParams params,
    int orderId,
    PaymentResponse paymentResponse,
  ) async {
    switch (paymentResponse.res) {
      case '0000':
        await _handleSuccessfulPayment(params, orderId, paymentResponse);
      case '1004':
        await _handleFailedPayment(params, orderId, paymentResponse, '시간초과');
        throw PaymentRefundableException(
          '시간 초과 결제 실패',
          orderId: orderId,
          approvalNo: paymentResponse.approvalNo ?? '',
          tradeTime: paymentResponse.tradeTime,
          description: '시간초과',
        );
      case '1000':
        await _handleFailedPayment(params, orderId, paymentResponse, '고객취소');
        throw PaymentRefundableException(
          '취소된 결제 실패',
          orderId: orderId,
          approvalNo: paymentResponse.approvalNo ?? '',
          tradeTime: paymentResponse.tradeTime,
          description: '고객취소',
        );
      default:
        await _handleFailedPayment(params, orderId, paymentResponse, '확인필요');
        throw PaymentRefundableException(
          '결제 상태를 확인할 수 없습니다.',
          orderId: orderId,
          approvalNo: paymentResponse.approvalNo ?? '',
          tradeTime: paymentResponse.tradeTime,
          description: '확인필요',
        );
    }
  }

  Future<void> _handleSuccessfulPayment(
    ProcessPaymentParams params,
    int orderId,
    PaymentResponse paymentResponse,
  ) async {
    final response = await _orderUpdate.updateOrder(UpdateOrderParams(
      kioskEventId: params.kioskEventId,
      kioskMachineId: params.kioskMachineId,
      photoCardPrice: params.photoCardPrice,
      photoAuthNumber: params.photoAuthNumber,
      approval: paymentResponse,
      orderId: orderId,
      isRefund: false,
    ));
    _slackLog.sendLog('paymentResponse0000 : $response');
  }

  Future<void> _handleFailedPayment(
    ProcessPaymentParams params,
    int orderId,
    PaymentResponse paymentResponse,
    String description,
  ) async {
    await _orderUpdate.updateOrder(UpdateOrderParams(
      kioskEventId: params.kioskEventId,
      kioskMachineId: params.kioskMachineId,
      photoCardPrice: params.photoCardPrice,
      photoAuthNumber: params.photoAuthNumber,
      approval: paymentResponse,
      orderId: orderId,
      isRefund: false,
      description: description,
    ));
  }

  String _formatPaymentMessages(PaymentResponse paymentResponse) {
    final message1 = paymentResponse.message1?.trim();
    final message2 = paymentResponse.message2?.trim();

    if ((message1 == null || message1.isEmpty) && (message2 == null || message2.isEmpty)) {
      return '확인필요';
    }
    if (message1 != null && message1.isNotEmpty && (message2 == null || message2.isEmpty)) {
      return message1;
    }
    if ((message1 == null || message1.isEmpty) && message2 != null && message2.isNotEmpty) {
      return message2;
    }
    return '$message1($message2)';
  }
}
