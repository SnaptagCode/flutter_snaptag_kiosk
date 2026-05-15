import 'package:flutter_snaptag_kiosk/domain/repositories/i_kiosk_repository.dart';
import 'package:flutter_snaptag_kiosk/domain/services/i_slack_log_service.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';

class UpdateOrderParams {
  final int kioskEventId;
  final int kioskMachineId;
  final int photoCardPrice;
  final String photoAuthNumber;
  final PaymentResponse? approval;
  final int orderId;
  final bool isRefund;
  final String? description;

  const UpdateOrderParams({
    required this.kioskEventId,
    required this.kioskMachineId,
    required this.photoCardPrice,
    required this.photoAuthNumber,
    this.approval,
    required this.orderId,
    required this.isRefund,
    this.description,
  });
}

class OrderUpdateService {
  final IKioskRepository _repository;
  final ISlackLogService _slackLog;

  const OrderUpdateService(this._repository, this._slackLog);

  Future<UpdateOrderResponse> updateOrder(UpdateOrderParams params) async {
    const maxRetries = 3;
    const retryDelay = Duration(milliseconds: 500);

    final OrderStatus defaultStatus = params.isRefund ? OrderStatus.refunded_failed : OrderStatus.failed;
    final OrderStatus orderStatus = (params.isRefund && params.approval?.orderState == OrderStatus.failed)
        ? OrderStatus.refunded_failed
        : params.approval?.orderState ?? defaultStatus;

    final approvalNo = (params.approval?.approvalNo?.trim() ?? '').isEmpty ? '-' : params.approval!.approvalNo!;

    final request = UpdateOrderRequest(
      kioskEventId: params.kioskEventId,
      kioskMachineId: params.kioskMachineId,
      photoAuthNumber: params.photoAuthNumber,
      amount: params.photoCardPrice,
      status: orderStatus,
      approvalNumber: approvalNo,
      purchaseAuthNumber: approvalNo,
      authSeqNumber: approvalNo,
      detail: params.approval?.KSNET ?? '{}',
      description: params.description,
    );

    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        return await _repository.updateOrderStatus(params.orderId, request);
      } catch (e) {
        if (attempt == maxRetries) {
          _slackLog.sendLog('update order error (attempt $attempt/$maxRetries): $e');
          rethrow;
        }
        logger.w('update order attempt $attempt failed, retrying in ${retryDelay.inMilliseconds}ms... $e');
        await Future.delayed(retryDelay);
      }
    }
    throw Exception('unreachable');
  }
}
