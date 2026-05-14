import 'package:flutter_snaptag_kiosk/domain/models/verification/back_photo_card.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:flutter_snaptag_kiosk/presentation/core/card_count_provider.dart';
import 'package:flutter_snaptag_kiosk/presentation/kiosk_shell/kiosk_info_service.dart';
import 'package:flutter_snaptag_kiosk/payment/presentation/notifier/create_order_info_notifier.dart';
import 'package:flutter_snaptag_kiosk/payment/domain/failure/payment_failure.dart';
import 'package:flutter_snaptag_kiosk/payment/presentation/notifier/payment_response_notifier.dart';
import 'package:flutter_snaptag_kiosk/presentation/setup/main/notifiers/page_print_notifier.dart';
import 'package:flutter_snaptag_kiosk/verification/presentation/notifier/auth_code_notifier.dart';
import 'package:flutter_snaptag_kiosk/presentation/core/back_photo_session_notifier.dart';
import 'package:intl/intl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'payment_service.g.dart';

@riverpod
class PaymentService extends _$PaymentService {
  @override
  FutureOr<void> build() => null;

  Future<void> processPayment() async {
    // 1. 사전 검증
    _validatePreconditions();

    // 2. 주문 생성
    final orderResponse = await _createOrder().catchError((e) => throw OrderCreationException('Create order fail: $e'));
    ref.read(createOrderInfoProvider.notifier).update(orderResponse);

    try {
      // 3. 결제 승인 및 처리
      final paymentResponse = await _approvePayment();
      await _handlePaymentResult(paymentResponse);
    } catch (e) {
      // PaymentFailedException은 이미 처리된 예외이므로 그대로 rethrow
      if (e is PaymentFailedException) {
        logger.e('Payment process failed', error: e);
        rethrow;
      }
      // 그 외 예외(네트워크 오류, API 오류 등)는 주문 업데이트 후 PaymentProcessingException으로 변환
      await _handlePaymentError();
      logger.e('Payment process failed', error: e);
      throw PaymentProcessingException("결제 처리 중 오류가 발생했습니다.");
    }
  }

  /// 사전 조건 검증
  void _validatePreconditions() {
    final settings = ref.read(kioskInfoServiceProvider);
    final backPhoto = ref.read(backPhotoSessionProvider).value;

    if (settings == null) {
      throw PreconditionFailedException('No kiosk settings available');
    }
    if (backPhoto == null) {
      throw PreconditionFailedException('No back photo available');
    }
  }

  /// 결제 승인 처리
  Future<PaymentResponse> _approvePayment() async {
    final price = ref.read(kioskInfoServiceProvider)!.photoCardPrice;
    final paymentResponse = await ref.read(paymentRepositoryProvider).approve(
          totalAmount: price,
        );
    ref.read(paymentResponseStateProvider.notifier).update(paymentResponse);
    return paymentResponse;
  }

  /// message1과 message2를 포맷팅하는 헬퍼 함수
  String _formatPaymentMessages(PaymentResponse paymentResponse) {
    final message1 = paymentResponse.message1?.trim();
    final message2 = paymentResponse.message2?.trim();

    // 둘 다 없는 경우
    if ((message1 == null || message1.isEmpty) && (message2 == null || message2.isEmpty)) {
      return "확인필요";
    }

    // message1만 있는 경우
    if (message1 != null && message1.isNotEmpty && (message2 == null || message2.isEmpty)) {
      return message1;
    }

    // message2만 있는 경우
    if ((message1 == null || message1.isEmpty) && message2 != null && message2.isNotEmpty) {
      return message2;
    }

    // 둘 다 있는 경우
    return "$message1($message2)";
  }

  /// 결제 결과 처리
  Future<void> _handlePaymentResult(PaymentResponse paymentResponse) async {
    final approvalNo = paymentResponse.approvalNo ?? '';
    final machineId = ref.read(kioskInfoServiceProvider)!.kioskMachineId.toString();

    if (approvalNo.trim().isEmpty && paymentResponse.res == '0000') {
      await _handleEmptyApprovalNumber(paymentResponse, machineId);
    } else {
      await _handlePaymentResponse(paymentResponse);
    }
  }

  /// 승인번호가 없는 결제 처리
  Future<void> _handleEmptyApprovalNumber(PaymentResponse paymentResponse, String machineId) async {
    final backPhoto = ref.read(backPhotoSessionProvider).value!;

    await _updateFailOrder(description: _formatPaymentMessages(paymentResponse));

    SlackLogService().sendPaymentBroadcastLogToSlak(InfoKey.paymentFail.key,
        paymentDescription:
            "사유: ${_formatPaymentMessages(paymentResponse)}\n- 인증번호: ${backPhoto.photoAuthNumber}\n- 승인번호: ${paymentResponse.approvalNo ?? "없음"}");

    throw EmptyApprovalNumberException(description: _formatPaymentMessages(paymentResponse));
  }

  /// 결제 응답 처리
  Future<void> _handlePaymentResponse(PaymentResponse paymentResponse) async {
    final backPhoto = ref.read(backPhotoSessionProvider).value!;

    SlackLogService().sendLogToSlack("paymentResponse : $paymentResponse");

    switch (paymentResponse.res) {
      case '0000':
        await _handleSuccessfulPayment();
        break;
      case '1004':
        await _handleTimeoutPayment(backPhoto, paymentResponse);
        break;
      case '1000':
        await _handleCancelledPayment(backPhoto, paymentResponse);
        break;
      default:
        await _handleUnknownPayment();
    }
  }

  /// 성공적인 결제 처리
  Future<void> _handleSuccessfulPayment() async {
    final response = await _updateOrder(isRefund: false);
    await ref.read(cardCountProvider.notifier).decrease();
    SlackLogService().sendLogToSlack("paymentResponse0000 : $response");
  }

  /// 시간 초과 결제 처리
  Future<void> _handleTimeoutPayment(BackPhotoCard backPhoto, PaymentResponse paymentResponse) async {
    final response = await _updateOrder(isRefund: false, description: "시간초과");
    SlackLogService().sendLogToSlack("paymentResponse1004 : $response");
    throw TimeoutPaymentException(description: "시간초과");
  }

  /// 취소된 결제 처리
  Future<void> _handleCancelledPayment(BackPhotoCard backPhoto, PaymentResponse paymentResponse) async {
    await _updateOrder(isRefund: false, description: "고객취소");
    throw CancelledPaymentException(description: "고객취소");
  }

  /// 알 수 없는 결제 상태 처리
  Future<void> _handleUnknownPayment() async {
    await _updateOrder(isRefund: false, description: "확인필요");
    throw UnknownPaymentException(description: "확인필요");
  }

  /// 결제 오류 처리 (주문 상태만 업데이트, Exception은 throw하지 않음)
  Future<void> _handlePaymentError() async {
    await _updateOrder(isRefund: false, description: "확인필요");
  }

  Future<void> refund() async {
    try {
      final approvalInfo = ref.read(paymentResponseStateProvider);
      if (approvalInfo == null) {
        throw Exception('No payment approval info available');
      }
      final approvalNo = approvalInfo.approvalNo ?? '';
      if (approvalNo.trim().isEmpty) {
        throw Exception('No approval number available');
      }

      final price = ref.read(kioskInfoServiceProvider)!.photoCardPrice;
      final paymentResponse = await ref.read(paymentRepositoryProvider).cancel(
            totalAmount: price,
            originalApprovalNo: approvalInfo.approvalNo ?? '',
            originalApprovalDate: approvalInfo.tradeTime?.substring(0, 6) ?? '',
          );
      logger.i(
          'respCode: ${approvalInfo.respCode} \trespCode: ${approvalInfo.respCode} \nORDER STATUS: ${approvalInfo.orderState}');
      ref.read(paymentResponseStateProvider.notifier).update(paymentResponse);
    } catch (e) {
      logger.e('Refund failed', error: e);
      rethrow;
    } finally {
      final approvalInfo = ref.read(paymentResponseStateProvider);
      final backPhoto = ref.read(backPhotoSessionProvider).value;
      final paymentRes = approvalInfo?.res;
      if (approvalInfo?.orderState == OrderStatus.refunded) {
        await _updateOrder(isRefund: true, description: "자동환불");
        SlackLogService().sendPaymentBroadcastLogToSlak(InfoKey.paymentRefund.key,
            paymentDescription:
                "동작로직: 자동환불\n- 인증번호: ${backPhoto?.photoAuthNumber ?? "없음"}\n- 승인번호: ${approvalInfo?.approvalNo ?? "없음"}");
        ref.read(paymentResponseStateProvider.notifier).reset();
        SlackLogService().sendLogToSlack('paymentResponseState Reset');
      } else {
        switch (paymentRes) {
          case '1000':
            await _updateOrder(isRefund: true, description: "고객취소");
            SlackLogService().sendPaymentBroadcastLogToSlak(InfoKey.paymentRefundFail.key,
                paymentDescription:
                    "동작로직: 자동환불\n- 사유: 사용자가 환불취소 누름\n- 인증번호: ${backPhoto?.photoAuthNumber ?? "없음"}\n- 승인번호: ${approvalInfo?.approvalNo ?? "없음"}");
            break;
          case '1004':
            await _updateOrder(isRefund: true, description: "시간초과");
            SlackLogService().sendPaymentBroadcastLogToSlak(InfoKey.paymentRefundFail.key,
                paymentDescription:
                    "동작로직: 자동환불\n- 사유: 시간초과\n- 인증번호: ${backPhoto?.photoAuthNumber ?? "없음"}\n- 승인번호: ${approvalInfo?.approvalNo ?? "없음"}");
            break;
          default:
            await _updateOrder(isRefund: true, description: "확인필요");
            SlackLogService().sendPaymentBroadcastLogToSlak(InfoKey.paymentRefundFail.key,
                paymentDescription:
                    "동작로직: 자동환불\n- 사유: 확인필요\n- 인증번호: ${backPhoto?.photoAuthNumber ?? "없음"}\n- 승인번호: ${approvalInfo?.approvalNo ?? "없음"}");
        }
      }
    }
  }

  Future<bool> error409_refund(OrderErrorEntity order) async {
    bool isSuccess = false;
    try {
      final approvalInfo = order;
      if (approvalInfo == null) {
        throw Exception('No payment approval info available');
      }
      final approvalNo = approvalInfo.authSeqNumber ?? '';
      if (approvalNo.trim().isEmpty) {
        throw Exception('No approval number available');
      }

      final price = ref.read(kioskInfoServiceProvider)!.photoCardPrice;
      final paymentResponse = await ref.read(paymentRepositoryProvider).cancel(
            totalAmount: price,
            originalApprovalNo: approvalInfo.authSeqNumber ?? '',
            originalApprovalDate: DateFormat('yyMMdd').format(approvalInfo.completedAt!),
          );
      SlackLogService().sendLogToSlack('error409_refund paymentResponse: $paymentResponse');
      ref.read(paymentResponseStateProvider.notifier).update(paymentResponse);
      isSuccess = paymentResponse.isSuccess;
    } catch (e) {
      SlackLogService().sendLogToSlack('error409 refund fail error : $e');
      logger.e('Refund failed', error: e);
      rethrow;
    } finally {
      final code = ref.read(authCodeProvider);
      final approval = ref.read(paymentResponseStateProvider);
      if (approval?.orderState == OrderStatus.refunded) {
        final response =
            await _updateOrder(isRefund: true, orderid: order.orderId, photoAuthNumber: code, description: "환불안내");
        SlackLogService().sendLogToSlack('error409 response: $response');
        SlackLogService().sendPaymentBroadcastLogToSlak(InfoKey.paymentRefund.key,
            paymentDescription: "동작로직: 환불안내\n- 인증번호: $code\n- 승인번호: ${order.authSeqNumber ?? "없음"}");
        ref.read(paymentResponseStateProvider.notifier).reset();
        SlackLogService().sendLogToSlack('error409 paymentResponseState Reset');
      } else {
        final approvalInfo = ref.read(paymentResponseStateProvider);
        final paymentRes = approvalInfo?.res;
        switch (paymentRes) {
          case '1000':
            await _updateOrder(isRefund: true, orderid: order.orderId, photoAuthNumber: code, description: "고객취소");
            SlackLogService().sendPaymentBroadcastLogToSlak(InfoKey.paymentRefundFail.key,
                paymentDescription:
                    "동작로직: 환불안내\n- 사유: 사용자가 환불취소 누름\n- 인증번호: $code\n- 승인번호: ${approvalInfo?.approvalNo ?? "없음"}");
            break;
          case '1004':
            await _updateOrder(isRefund: true, orderid: order.orderId, photoAuthNumber: code, description: "시간초과");
            SlackLogService().sendPaymentBroadcastLogToSlak(InfoKey.paymentRefundFail.key,
                paymentDescription:
                    "동작로직: 환불안내\n- 사유: 시간초과\n- 인증번호: $code\n- 승인번호: ${approvalInfo?.approvalNo ?? "없음"}");
            break;
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

  Future<CreateOrderResponse> _createOrder() async {
    final settings = ref.read(kioskInfoServiceProvider);
    final backPhoto = ref.read(backPhotoSessionProvider).value;
    final isSingleSided = ref.read(pagePrintProvider) == PagePrintType.single;

    final request = CreateOrderRequest(
      kioskEventId: settings!.kioskEventId,
      kioskMachineId: settings.kioskMachineId,
      photoAuthNumber: backPhoto?.photoAuthNumber ?? '',
      amount: settings.photoCardPrice,
      paymentType: PaymentType.card,
      isSingleSided: isSingleSided,
    );

    return await ref.read(kioskRepositoryProvider).createOrderStatus(request);
  }

  Future<UpdateOrderResponse> _updateOrder(
      {required bool isRefund, int? orderid, String? photoAuthNumber, String? description}) async {
    const maxRetries = 3;
    const retryDelay = Duration(milliseconds: 500);

    final settings = ref.read(kioskInfoServiceProvider);
    final backPhotoAuthNumber = photoAuthNumber ?? ref.read(backPhotoSessionProvider).value?.photoAuthNumber;
    final approval = ref.read(paymentResponseStateProvider);
    final orderId = orderid ?? ref.read(createOrderInfoProvider)?.orderId;
    if (orderId == null) {
      throw Exception('No order id available');
    }
    logger
        .i('respCode: ${approval?.respCode} \trespCode: ${approval?.respCode} \nORDER STATUS: ${approval?.orderState}');
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
        return await ref.read(kioskRepositoryProvider).updateOrderStatus(orderId.toInt(), request);
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
    try {
      final settings = ref.read(kioskInfoServiceProvider);
      final backPhoto = ref.read(backPhotoSessionProvider).value;
      final approval = ref.read(paymentResponseStateProvider);
      final orderId = ref.read(createOrderInfoProvider)?.orderId;
      if (orderId == null) {
        throw Exception('No order id available');
      }
      logger.i(
          'respCode: ${approval?.respCode} \trespCode: ${approval?.respCode} \nORDER STATUS: ${approval?.orderState}');
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
          description: description);

      return await ref.read(kioskRepositoryProvider).updateOrderStatus(orderId.toInt(), request);
    } catch (e) {
      rethrow;
    }
  }
}
