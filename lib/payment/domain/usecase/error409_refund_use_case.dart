import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:flutter_snaptag_kiosk/payment/module/payment_di.dart';
import 'package:flutter_snaptag_kiosk/payment/presentation/notifier/create_order_info_notifier.dart';
import 'package:flutter_snaptag_kiosk/payment/presentation/notifier/payment_response_notifier.dart';
import 'package:flutter_snaptag_kiosk/presentation/core/back_photo_session_notifier.dart';
import 'package:flutter_snaptag_kiosk/presentation/kiosk_shell/kiosk_info_service.dart';
import 'package:flutter_snaptag_kiosk/verification/presentation/notifier/auth_code_notifier.dart';
import 'package:intl/intl.dart';

class Error409RefundUseCase {
  Error409RefundUseCase(this._ref);
  final Ref _ref;

  Future<bool> call(OrderErrorEntity order) async {
    bool isSuccess = false;
    try {
      final approvalNo = order.authSeqNumber ?? '';
      if (approvalNo.trim().isEmpty) {
        throw Exception('No approval number available');
      }

      final price = _ref.read(kioskInfoServiceProvider)!.photoCardPrice;
      final paymentResponse = await _ref.read(cancelPaymentUseCaseProvider).call(
            totalAmount: price,
            originalApprovalNo: order.authSeqNumber ?? '',
            originalApprovalDate: DateFormat('yyMMdd').format(order.completedAt!),
          );
      SlackLogService().sendLogToSlack('error409_refund paymentResponse: $paymentResponse');
      _ref.read(paymentResponseStateProvider.notifier).update(paymentResponse);
      isSuccess = paymentResponse.isSuccess;
    } catch (e) {
      SlackLogService().sendLogToSlack('error409 refund fail error : $e');
      logger.e('Refund failed', error: e);
      rethrow;
    } finally {
      final code = _ref.read(authCodeProvider);
      final approval = _ref.read(paymentResponseStateProvider);
      if (approval?.orderState == OrderStatus.refunded) {
        final response =
            await _updateOrder(isRefund: true, orderid: order.orderId, photoAuthNumber: code, description: "환불안내");
        SlackLogService().sendLogToSlack('error409 response: $response');
        SlackLogService().sendPaymentBroadcastLogToSlak(InfoKey.paymentRefund.key,
            paymentDescription: "동작로직: 환불안내\n- 인증번호: $code\n- 승인번호: ${order.authSeqNumber ?? "없음"}");
        _ref.read(paymentResponseStateProvider.notifier).reset();
        SlackLogService().sendLogToSlack('error409 paymentResponseState Reset');
      } else {
        final approvalInfo = _ref.read(paymentResponseStateProvider);
        final paymentRes = approvalInfo?.res;
        switch (paymentRes) {
          case '1000':
            await _updateOrder(isRefund: true, orderid: order.orderId, photoAuthNumber: code, description: "고객취소");
            SlackLogService().sendPaymentBroadcastLogToSlak(InfoKey.paymentRefundFail.key,
                paymentDescription:
                    "동작로직: 환불안내\n- 사유: 사용자가 환불취소 누름\n- 인증번호: $code\n- 승인번호: ${approvalInfo?.approvalNo ?? "없음"}");
          case '1004':
            await _updateOrder(isRefund: true, orderid: order.orderId, photoAuthNumber: code, description: "시간초과");
            SlackLogService().sendPaymentBroadcastLogToSlak(InfoKey.paymentRefundFail.key,
                paymentDescription:
                    "동작로직: 환불안내\n- 사유: 시간초과\n- 인증번호: $code\n- 승인번호: ${approvalInfo?.approvalNo ?? "없음"}");
          default:
            await _updateOrder(isRefund: true, orderid: order.orderId, photoAuthNumber: code, description: "확인필요");
            SlackLogService().sendPaymentBroadcastLogToSlak(InfoKey.paymentRefundFail.key,
                paymentDescription:
                    "동작로직: 환불안내\n- 사유: 확인필요\n- 인증번호: $code\n- 승인번호: ${approvalInfo?.approvalNo ?? "없음"}");
        }
      }
    }
    return isSuccess;
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
}
