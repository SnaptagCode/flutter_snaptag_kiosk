import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:flutter_snaptag_kiosk/presentation/payment/di/payment_di.dart';
import 'package:flutter_snaptag_kiosk/presentation/payment/notifier/create_order_info_notifier.dart';
import 'package:flutter_snaptag_kiosk/presentation/payment/notifier/payment_response_notifier.dart';
import 'package:flutter_snaptag_kiosk/presentation/core/back_photo_session_notifier.dart';
import 'package:flutter_snaptag_kiosk/presentation/kiosk_shell/kiosk_info_service.dart';

class RefundPaymentUseCase {
  RefundPaymentUseCase(this._ref);
  final Ref _ref;

  Future<void> call() async {
    try {
      final approvalInfo = _ref.read(paymentResponseStateProvider);
      if (approvalInfo == null) {
        throw Exception('No payment approval info available');
      }
      final approvalNo = approvalInfo.approvalNo ?? '';
      if (approvalNo.trim().isEmpty) {
        throw Exception('No approval number available');
      }

      final price = _ref.read(kioskInfoServiceProvider)!.photoCardPrice;
      final paymentResponse = await _ref.read(cancelPaymentUseCaseProvider).call(
            totalAmount: price,
            originalApprovalNo: approvalInfo.approvalNo ?? '',
            originalApprovalDate: approvalInfo.tradeTime?.substring(0, 6) ?? '',
          );
      logger.i(
          'respCode: ${approvalInfo.respCode} \trespCode: ${approvalInfo.respCode} \nORDER STATUS: ${approvalInfo.orderState}');
      _ref.read(paymentResponseStateProvider.notifier).update(paymentResponse);
    } catch (e) {
      logger.e('Refund failed', error: e);
      rethrow;
    } finally {
      final approvalInfo = _ref.read(paymentResponseStateProvider);
      final backPhoto = _ref.read(backPhotoSessionProvider).value;
      final paymentRes = approvalInfo?.res;
      if (approvalInfo?.orderState == OrderStatus.refunded) {
        await _updateOrder(isRefund: true, description: "자동환불");
        SlackLogService().sendPaymentBroadcastLogToSlak(InfoKey.paymentRefund.key,
            paymentDescription:
                "동작로직: 자동환불\n- 인증번호: ${backPhoto?.photoAuthNumber ?? "없음"}\n- 승인번호: ${approvalInfo?.approvalNo ?? "없음"}");
        _ref.read(paymentResponseStateProvider.notifier).reset();
        SlackLogService().sendLogToSlack('paymentResponseState Reset');
      } else {
        switch (paymentRes) {
          case '1000':
            await _updateOrder(isRefund: true, description: "고객취소");
            SlackLogService().sendPaymentBroadcastLogToSlak(InfoKey.paymentRefundFail.key,
                paymentDescription:
                    "동작로직: 자동환불\n- 사유: 사용자가 환불취소 누름\n- 인증번호: ${backPhoto?.photoAuthNumber ?? "없음"}\n- 승인번호: ${approvalInfo?.approvalNo ?? "없음"}");
          case '1004':
            await _updateOrder(isRefund: true, description: "시간초과");
            SlackLogService().sendPaymentBroadcastLogToSlak(InfoKey.paymentRefundFail.key,
                paymentDescription:
                    "동작로직: 자동환불\n- 사유: 시간초과\n- 인증번호: ${backPhoto?.photoAuthNumber ?? "없음"}\n- 승인번호: ${approvalInfo?.approvalNo ?? "없음"}");
          default:
            await _updateOrder(isRefund: true, description: "확인필요");
            SlackLogService().sendPaymentBroadcastLogToSlak(InfoKey.paymentRefundFail.key,
                paymentDescription:
                    "동작로직: 자동환불\n- 사유: 확인필요\n- 인증번호: ${backPhoto?.photoAuthNumber ?? "없음"}\n- 승인번호: ${approvalInfo?.approvalNo ?? "없음"}");
        }
      }
    }
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
