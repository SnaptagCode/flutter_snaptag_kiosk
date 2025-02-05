import 'dart:convert';

import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'payment_response.freezed.dart';
part 'payment_response.g.dart';

@freezed
class PaymentResponse with _$PaymentResponse {
  const PaymentResponse._(); // freezed에서 메서드를 추가하기 위한 private constructor

  const factory PaymentResponse({
    @JsonKey(name: 'APPROVALNO') String? approvalNo,
    @JsonKey(name: 'CARDNAME') String? cardName,
    @JsonKey(name: 'CARDTYPE') String? cardType,
    @JsonKey(name: 'CLASSFLAG') String? classFlag,
    @JsonKey(name: 'COMPANYINFO') String? companyInfo,
    @JsonKey(name: 'CORPRESPCODE') String? corpRespCode,
    @JsonKey(name: 'RES') required String res,
    @JsonKey(name: 'RESPCODE') String? respCode,
    @JsonKey(name: 'MSG') String? msg,
    @JsonKey(name: 'MESSAGE1') String? message1,
    @JsonKey(name: 'MESSAGE2') String? message2,
    @JsonKey(name: 'TELEGRAMFLAG') String? telegramFlag,
    @JsonKey(name: 'TRADEUNIQUENO') String? tradeUniqueNo,
    @JsonKey(name: 'TRADETIME') String? tradeTime,
    @JsonKey(name: 'STATUS') String? status,
    @JsonKey(name: 'KSNET') String? ksnet,
  }) = _PaymentResponse;

  factory PaymentResponse.fromJson(Map<String, dynamic> json) => _$PaymentResponseFromJson(json);
}

extension PaymentResponseExtension on PaymentResponse {
  /// 이미 취소된 거래
  bool get isAlreadyCanceled => respCode == '7001';

  bool get isSuccess => res == '0000' && respCode == '0000';

  String get KSNET {
    Map<String, dynamic> data = {"KSNET": ksnet};
    return jsonEncode(data);
  }

  ///
  /// 0: 실패
  ///
  /// 1: 성공
  ///
  /// 2: 기타 오류
  ///
  int get code {
    // RES 코드 체크 (주요 오류 상태)
    switch (res) {
      case '1000':
      case '1003':
      case '1004':
        return 0;
      case '0000':
        // RES가 정상이면 RESPCODE 확인
        switch (respCode) {
          case '0000':
            return 1;
          case '7001':
          case '7002':
          case '7003':
          case '8324':
          case '8325':
          case '8326':
          case '8327':
          case '8328':
          case '8329':
          case '8330':
          case '8331':
          case '8332':
          case '8350':
          default:
            return 2;
        }
      default:
        return 2;
    }
  }

  ///
  /// `0210`: 결제 요청 Response
  ///
  ///   -> return 1
  ///
  /// `0430`: 취소 요청 Response
  ///
  ///   -> return 2
  ///
  /// `0450`: 망취소 Response (승인 번호 없음)
  ///
  /// `0470`: 망취소 Response (승인 번호 있음)
  ///
  ///   -> return 0
  ///
  int get requestType {
    switch (telegramFlag) {
      case '0210':
        return 1;
      case '0430':
        return 2;
      case '0450':
      case '0470':
      default:
        return 0;
    }
  }

  OrderStatus get orderState {
    if (requestType == 1) {
      switch (code) {
        case 1:
          return OrderStatus.completed;
        case 2:
        case 0:
        default:
          return OrderStatus.failed;
      }
    } else if (requestType == 2) {
      switch (code) {
        case 1:
          return OrderStatus.refunded;
        case 2:
        case 0:
        default:
          return OrderStatus.refunded_failed;
      }
    } else {
      return OrderStatus.failed;
    }
  }
}
