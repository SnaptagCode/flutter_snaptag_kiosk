import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_snaptag_kiosk/domain/models/verification/back_photo_card.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:flutter_snaptag_kiosk/payment/domain/failure/payment_failure.dart';
import 'package:flutter_snaptag_kiosk/payment/module/payment_di.dart';
import 'package:flutter_snaptag_kiosk/payment/presentation/notifier/create_order_info_notifier.dart';
import 'package:flutter_snaptag_kiosk/payment/presentation/notifier/payment_response_notifier.dart';
import 'package:flutter_snaptag_kiosk/presentation/core/back_photo_session_notifier.dart';
import 'package:flutter_snaptag_kiosk/presentation/core/card_count_provider.dart';
import 'package:flutter_snaptag_kiosk/presentation/kiosk_shell/kiosk_info_service.dart';
import 'package:flutter_snaptag_kiosk/presentation/setup/main/notifiers/page_print_notifier.dart';

class ProcessPaymentUseCase {
  ProcessPaymentUseCase(this._ref);
  final Ref _ref;

  Future<void> call() async {
    _validatePreconditions();

    final orderResponse = await _createOrder().catchError((e) => throw OrderCreationException('Create order fail: $e'));
    _ref.read(createOrderInfoProvider.notifier).update(orderResponse);

    try {
      final paymentResponse = await _approvePayment();
      await _handlePaymentResult(paymentResponse);
    } catch (e) {
      if (e is PaymentFailedException) {
        logger.e('Payment process failed', error: e);
        rethrow;
      }
      await _handlePaymentError();
      logger.e('Payment process failed', error: e);
      throw PaymentProcessingException("결제 처리 중 오류가 발생했습니다.");
    }
  }

  void _validatePreconditions() {
    final settings = _ref.read(kioskInfoServiceProvider);
    final backPhoto = _ref.read(backPhotoSessionProvider).value;

    if (settings == null) {
      throw PreconditionFailedException('No kiosk settings available');
    }
    if (backPhoto == null) {
      throw PreconditionFailedException('No back photo available');
    }
  }

  Future<PaymentResponse> _approvePayment() async {
    final price = _ref.read(kioskInfoServiceProvider)!.photoCardPrice;
    final paymentResponse = await _ref.read(approvePaymentUseCaseProvider).call(
          totalAmount: price,
        );
    _ref.read(paymentResponseStateProvider.notifier).update(paymentResponse);
    return paymentResponse;
  }

  String _formatPaymentMessages(PaymentResponse paymentResponse) {
    final message1 = paymentResponse.message1?.trim();
    final message2 = paymentResponse.message2?.trim();

    if ((message1 == null || message1.isEmpty) && (message2 == null || message2.isEmpty)) {
      return "확인필요";
    }
    if (message1 != null && message1.isNotEmpty && (message2 == null || message2.isEmpty)) {
      return message1;
    }
    if ((message1 == null || message1.isEmpty) && message2 != null && message2.isNotEmpty) {
      return message2;
    }
    return "$message1($message2)";
  }

  Future<void> _handlePaymentResult(PaymentResponse paymentResponse) async {
    final approvalNo = paymentResponse.approvalNo ?? '';

    if (approvalNo.trim().isEmpty && paymentResponse.res == '0000') {
      await _handleEmptyApprovalNumber(paymentResponse);
    } else {
      await _handlePaymentResponse(paymentResponse);
    }
  }

  Future<void> _handleEmptyApprovalNumber(PaymentResponse paymentResponse) async {
    final backPhoto = _ref.read(backPhotoSessionProvider).value!;

    await _updateFailOrder(description: _formatPaymentMessages(paymentResponse));

    SlackLogService().sendPaymentBroadcastLogToSlak(InfoKey.paymentFail.key,
        paymentDescription:
            "사유: ${_formatPaymentMessages(paymentResponse)}\n- 인증번호: ${backPhoto.photoAuthNumber}\n- 승인번호: ${paymentResponse.approvalNo ?? "없음"}");

    throw EmptyApprovalNumberException(description: _formatPaymentMessages(paymentResponse));
  }

  Future<void> _handlePaymentResponse(PaymentResponse paymentResponse) async {
    SlackLogService().sendLogToSlack("paymentResponse : $paymentResponse");

    switch (paymentResponse.res) {
      case '0000':
        await _handleSuccessfulPayment();
      case '1004':
        await _handleTimeoutPayment();
      case '1000':
        await _handleCancelledPayment();
      default:
        await _handleUnknownPayment();
    }
  }

  Future<void> _handleSuccessfulPayment() async {
    final response = await _updateOrder(isRefund: false);
    await _ref.read(cardCountProvider.notifier).decrease();
    SlackLogService().sendLogToSlack("paymentResponse0000 : $response");
  }

  Future<void> _handleTimeoutPayment() async {
    final response = await _updateOrder(isRefund: false, description: "시간초과");
    SlackLogService().sendLogToSlack("paymentResponse1004 : $response");
    throw TimeoutPaymentException(description: "시간초과");
  }

  Future<void> _handleCancelledPayment() async {
    await _updateOrder(isRefund: false, description: "고객취소");
    throw CancelledPaymentException(description: "고객취소");
  }

  Future<void> _handleUnknownPayment() async {
    await _updateOrder(isRefund: false, description: "확인필요");
    throw UnknownPaymentException(description: "확인필요");
  }

  Future<void> _handlePaymentError() async {
    await _updateOrder(isRefund: false, description: "확인필요");
  }

  Future<CreateOrderResponse> _createOrder() async {
    final settings = _ref.read(kioskInfoServiceProvider);
    final backPhoto = _ref.read(backPhotoSessionProvider).value;
    final isSingleSided = _ref.read(pagePrintProvider) == PagePrintType.single;

    final request = CreateOrderRequest(
      kioskEventId: settings!.kioskEventId,
      kioskMachineId: settings.kioskMachineId,
      photoAuthNumber: backPhoto?.photoAuthNumber ?? '',
      amount: settings.photoCardPrice,
      paymentType: PaymentType.card,
      isSingleSided: isSingleSided,
    );

    return await _ref.read(kioskRepositoryProvider).createOrderStatus(request);
  }

  Future<UpdateOrderResponse> _updateOrder(
      {required bool isRefund, int? orderid, String? photoAuthNumber, String? description}) async {
    const maxRetries = 3;
    const retryDelay = Duration(milliseconds: 500);

    final settings = _ref.read(kioskInfoServiceProvider);
    final backPhotoAuthNumber = photoAuthNumber ?? _ref.read(backPhotoSessionProvider).value?.photoAuthNumber;
    final approval = _ref.read(paymentResponseStateProvider);
    final orderId = orderid ?? _ref.read(createOrderInfoProvider)?.orderId;
    if (orderId == null) {
      throw Exception('No order id available');
    }
    logger.i('respCode: ${approval?.respCode} \trespCode: ${approval?.respCode} \nORDER STATUS: ${approval?.orderState}');
    final OrderStatus defaultStatus = isRefund ? OrderStatus.refunded_failed : OrderStatus.failed;
    final OrderStatus orderStatus = (isRefund && approval?.orderState == OrderStatus.failed)
        ? OrderStatus.refunded_failed
        : approval?.orderState ?? defaultStatus;
    final request = UpdateOrderRequest(
      kioskEventId: settings!.kioskEventId,
      kioskMachineId: settings.kioskMachineId,
      photoAuthNumber: backPhotoAuthNumber ?? '-',
      amount: settings.photoCardPrice,
      status: orderStatus,
      approvalNumber: approval?.approvalNo ?? '-',
      purchaseAuthNumber: approval?.approvalNo ?? '-',
      authSeqNumber: approval?.approvalNo ?? '-',
      detail: approval?.KSNET ?? '{}',
      description: description,
    );

    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        return await _ref.read(kioskRepositoryProvider).updateOrderStatus(orderId.toInt(), request);
      } catch (e) {
        if (attempt == maxRetries) {
          SlackLogService().sendLogToSlack('update order error (attempt $attempt/$maxRetries): $e');
          rethrow;
        }
        logger.w('update order attempt $attempt failed, retrying in ${retryDelay.inMilliseconds}ms... $e');
        await Future.delayed(retryDelay);
      }
    }
    throw Exception('unreachable');
  }

  Future<UpdateOrderResponse> _updateFailOrder({required String description}) async {
    final settings = _ref.read(kioskInfoServiceProvider);
    final backPhoto = _ref.read(backPhotoSessionProvider).value;
    final approval = _ref.read(paymentResponseStateProvider);
    final orderId = _ref.read(createOrderInfoProvider)?.orderId;
    if (orderId == null) {
      throw Exception('No order id available');
    }
    logger.i('respCode: ${approval?.respCode} \trespCode: ${approval?.respCode} \nORDER STATUS: ${approval?.orderState}');
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
      description: description,
    );

    return await _ref.read(kioskRepositoryProvider).updateOrderStatus(orderId.toInt(), request);
  }
}
