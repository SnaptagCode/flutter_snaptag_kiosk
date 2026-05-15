import 'dart:convert';

import 'package:flutter_snaptag_kiosk/domain/models/enums/order_status.dart';

class PaymentResult {
  final String? approvalNo;
  final String res;
  final String? respCode;
  final String? message1;
  final String? message2;
  final String? telegramFlag;
  final String? tradeTime;
  final String? ksnet;

  const PaymentResult({
    this.approvalNo,
    required this.res,
    this.respCode,
    this.message1,
    this.message2,
    this.telegramFlag,
    this.tradeTime,
    this.ksnet,
  });

  bool get isAlreadyCanceled => respCode == '7001';
  bool get isSuccess => res == '0000' && respCode == '0000';
  bool get isApprovalNoEmpty => approvalNo == null || approvalNo!.trim().isEmpty;

  String get KSNET => jsonEncode({'KSNET': ksnet});

  int get _code {
    switch (res) {
      case '1000':
      case '1003':
      case '1004':
        return 0;
      case '0000':
        if (respCode == '0000') return isApprovalNoEmpty ? 0 : 1;
        return 2;
      default:
        return 2;
    }
  }

  int get _requestType {
    switch (telegramFlag) {
      case '0210':
        return 1;
      case '0430':
        return 2;
      default:
        return 0;
    }
  }

  OrderStatus get orderState {
    if (_requestType == 1) {
      return _code == 1 ? OrderStatus.completed : OrderStatus.failed;
    } else if (_requestType == 2) {
      return _code == 1 ? OrderStatus.refunded : OrderStatus.refunded_failed;
    }
    return OrderStatus.failed;
  }

  @override
  String toString() =>
      'PaymentResult(res: $res, respCode: $respCode, approvalNo: $approvalNo, tradeTime: $tradeTime)';
}
