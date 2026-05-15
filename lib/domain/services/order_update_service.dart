import 'package:flutter_snaptag_kiosk/core/core.dart';
import 'package:flutter_snaptag_kiosk/domain/models/order/update_order_params.dart';
import 'package:flutter_snaptag_kiosk/domain/repositories/i_kiosk_repository.dart';
import 'package:flutter_snaptag_kiosk/domain/services/i_slack_log_service.dart';

export 'package:flutter_snaptag_kiosk/domain/models/order/update_order_params.dart';

class OrderUpdateService {
  final IKioskRepository _repository;
  final ISlackLogService _slackLog;

  const OrderUpdateService(this._repository, this._slackLog);

  Future<void> updateOrder(UpdateOrderParams params) async {
    const maxRetries = 3;
    const retryDelay = Duration(milliseconds: 500);

    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        await _repository.updateOrderStatus(params.orderId, params);
        return;
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
