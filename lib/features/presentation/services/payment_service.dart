import 'package:flutter_snaptag_kiosk/data/models/request/update_back_photo_request.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_snaptag_kiosk/features/move_me/providers/payment_failure_provider.dart';
import 'package:intl/intl.dart';

part 'payment_service.g.dart';

@riverpod
class PaymentService extends _$PaymentService {
  @override
  FutureOr<void> build() => null;

  Future<void> processPayment() async {
    // 1. 사전 검증
    final settings = ref.read(kioskInfoServiceProvider);
    final backPhoto = ref.watch(verifyPhotoCardProvider).value;

    if (settings == null) {
      throw PreconditionFailedException('No kiosk settings available');
    }
    if (backPhoto == null) {
      throw PreconditionFailedException('No back photo available');
    }

    // 2. 주문 생성
    final orderResponse = await _createOrder().catchError((e) => throw OrderCreationException('Create order fail: $e'));
    ref.read(createOrderInfoProvider.notifier).update(orderResponse);

    try {
      // 3. 결제 승인
      final price = ref.read(kioskInfoServiceProvider)!.photoCardPrice;
      final paymentResponse = await ref.read(paymentRepositoryProvider).approve(
            totalAmount: price,
          );
      ref.read(paymentResponseStateProvider.notifier).update(paymentResponse);
      final approvalNo = paymentResponse.approvalNo ?? '';
      final machineId = ref.read(kioskInfoServiceProvider)!.kioskMachineId;
      if (approvalNo.trim().isEmpty && paymentResponse.res == '0000') {
        //승인번호가 빈 결제 건
        SlackLogService().sendWarningLogToSlack('*[MachineId: $machineId]*\nNull approvalNo Card');
        final BackPhotoStatusResponse response =
            await ref.read(kioskRepositoryProvider).updateBackPhotoStatus(UpdateBackPhotoRequest(
                  photoAuthNumber: backPhoto.photoAuthNumber,
                  status: "STARTED",
                ));
        print("update status response : $response");
        ref.read(paymentFailureProvider.notifier).triggerFailure();
        final failResponse = await _updateFailOrder();
        ref.read(updateOrderInfoProvider.notifier).update(failResponse);
        SlackLogService().sendBroadcastLogToSlack(InfoKey.paymentFail.key,
            paymentDescription:
                "사유: 승인번호가 빈 결제 건\n        인증번호: ${backPhoto.photoAuthNumber}\n        승인번호: ${paymentResponse.approvalNo}");
      } else {
        final response = await updateOrder(isRefund: false); //결제 취소, 정상 결제
        ref.read(updateOrderInfoProvider.notifier).update(response);
        if (paymentResponse.res == '0000') {
          ref.read(cardCountProvider.notifier).decrease();
        } else if (paymentResponse.res == '1004') {
          SlackLogService().sendBroadcastLogToSlack(InfoKey.paymentFail.key,
              paymentDescription:
                  "사유: 시간초과\n        인증번호: ${backPhoto.photoAuthNumber}\n        승인번호: ${paymentResponse.approvalNo}");
        } else if (paymentResponse.res == '1000') {
          SlackLogService().sendBroadcastLogToSlack(InfoKey.paymentFail.key,
              paymentDescription:
                  "사유: 결제취소\n        인증번호: ${backPhoto.photoAuthNumber}\n        승인번호: ${paymentResponse.approvalNo}");
        }
      }
    } catch (e) {
      final response = await updateOrder(isRefund: false);
      ref.read(updateOrderInfoProvider.notifier).update(response);
      logger.e('Payment process failed', error: e);
      rethrow;
    } finally {
      // final response = await _updateOrder();
      // ref.read(updateOrderInfoProvider.notifier).update(response);
    }
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
      final paymentRes = approvalInfo?.res;
      final response = await _updateOrder(isRefund: true);
      if (response.status == OrderStatus.refunded) {
        SlackLogService().sendBroadcastLogToSlack(InfoKey.paymentRefund.key,
            paymentDescription: "동작로직: 자동환불\n        승인번호: ${approvalInfo?.approvalNo ?? "-"}");
        ref.read(paymentResponseStateProvider.notifier).reset();
        SlackLogService().sendLogToSlack('paymentResponseState Reset'); //paymentTestSlack
      } else {
        switch (paymentRes) {
          case '1000':
            SlackLogService().sendBroadcastLogToSlack(InfoKey.paymentRefundFail.key,
                paymentDescription: "동작로직: 자동환불\n        사유: 결제취소\n        승인번호: ${approvalInfo?.approvalNo ?? "-"}");
            break;
          case '1004':
            SlackLogService().sendBroadcastLogToSlack(InfoKey.paymentRefundFail.key,
                paymentDescription: "동작로직: 자동환불\n        사유: 시간초과\n        승인번호: ${approvalInfo?.approvalNo ?? "-"}");
            break;
          default:
            SlackLogService().sendBroadcastLogToSlack(InfoKey.paymentRefundFail.key,
                paymentDescription: "동작로직: 자동환불\n        사유: 확인필요\n        승인번호: ${approvalInfo?.approvalNo ?? "-"}");
        }
      }
    }
  }

  Future<bool> error409_refund(OrderErrorEntity order) async {
    bool isSuccess = false;
    try {
      //error 파싱
      final approvalInfo = order;
      if (approvalInfo == null) {
        //await SlackLogService().sendLogToSlack('start update(paymentResponse)');
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
      SlackLogService().sendLogToSlack('error409_refund paymentResponse: $paymentResponse'); //paymentTestSlack
      // logger.i(
      //     'respCode: ${approvalInfo.respCode} \trespCode: ${approvalInfo.respCode} \nORDER STATUS: ${approvalInfo.orderState}');
      ref.read(paymentResponseStateProvider.notifier).update(paymentResponse);
      isSuccess = paymentResponse.isSuccess;
    } catch (e) {
      SlackLogService().sendWarningLogToSlack('error409 refund fail error : $e');
      logger.e('Refund failed', error: e);
      rethrow;
    } finally {
      final code = ref.read(authCodeProvider);
      final response = await updateOrder(isRefund: true, orderid: order.orderId, photoAuthNumber: code);
      SlackLogService().sendLogToSlack('error409 response: $response'); //paymentTestSlack
      if (response.status == OrderStatus.refunded) {
        ref.read(paymentResponseStateProvider.notifier).reset();
        SlackLogService()
            .sendBroadcastLogToSlack(InfoKey.paymentRefund.key, paymentDescription: "동작로직: 환불안내\n        인증번호: $code");
        SlackLogService().sendLogToSlack('error409 paymentResponseState Reset'); //paymentTestSlack
      } else {
        final approvalInfo = ref.read(paymentResponseStateProvider);
        final paymentRes = approvalInfo?.res;
        switch (paymentRes) {
          case '1000':
            SlackLogService().sendBroadcastLogToSlack(InfoKey.paymentRefundFail.key,
                paymentDescription: "동작로직: 환불안내\n        사유: 결제취소\n        인증번호: $code");
            break;
          case '1004':
            SlackLogService().sendBroadcastLogToSlack(InfoKey.paymentRefundFail.key,
                paymentDescription: "동작로직: 환불안내\n        사유: 시간초과\n        인증번호: $code");
            break;
          default:
            SlackLogService().sendBroadcastLogToSlack(InfoKey.paymentRefundFail.key,
                paymentDescription: "동작로직: 환불안내\n        사유: 확인필요\n        인증번호: $code");
        }
      }
    }
    return isSuccess;
  }

  Future<CreateOrderResponse> _createOrder() async {
    final settings = ref.read(kioskInfoServiceProvider);
    final backPhoto = ref.watch(verifyPhotoCardProvider).value;
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

  Future<UpdateOrderResponse> updateOrder({required bool isRefund, int? orderid, String? photoAuthNumber}) async {
    try {
      final settings = ref.read(kioskInfoServiceProvider);
      final backPhotoAuthNumber = photoAuthNumber ?? ref.read(verifyPhotoCardProvider).value?.photoAuthNumber; //여기서 예외
      final approval = ref.read(paymentResponseStateProvider);
      final orderId = orderid ?? ref.read(createOrderInfoProvider)?.orderId;
      if (orderId == null) {
        throw Exception('No order id available');
      }
      logger.i(
          'respCode: ${approval?.respCode} \trespCode: ${approval?.respCode} \nORDER STATUS: ${approval?.orderState}');
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
      );

      return await ref.read(kioskRepositoryProvider).updateOrderStatus(orderId.toInt(), request);
    } catch (e) {
      SlackLogService().sendWarningLogToSlack('update order error: $e');
      rethrow;
    }
  }

  Future<UpdateOrderResponse> _updateFailOrder() async {
    try {
      final settings = ref.read(kioskInfoServiceProvider);
      final backPhoto = ref.watch(verifyPhotoCardProvider).value;
      final approval = ref.watch(paymentResponseStateProvider);
      final orderId = ref.watch(createOrderInfoProvider)?.orderId;
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
      );

      return await ref.read(kioskRepositoryProvider).updateOrderStatus(orderId.toInt(), request);
    } catch (e) {
      rethrow;
    }
  }
}

class OrderCreationException implements Exception {
  final String message;

  OrderCreationException(this.message);

  @override
  String toString() => 'OrderCreationException: $message';
}

class PreconditionFailedException implements Exception {
  final String message;

  PreconditionFailedException(this.message);

  @override
  String toString() => 'PreconditionFailedExption: $message';
}
