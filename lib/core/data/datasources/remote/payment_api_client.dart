import 'dart:convert';

import 'package:flutter_snaptag_kiosk/core/data/models/response/kscat_device_response.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:http/http.dart' as http;

class PaymentApiClient {
  PaymentApiClient();

  static const baseUrl = 'http://127.0.0.1:27098';

  Future<PaymentResponse> requestPayment(String callback, String request) async {
    // URL을 직접 구성 - 인코딩 없이
    final url = '$baseUrl?callback=$callback&REQ=$request';
    logger.i('\n=== Raw Payment Request URL ===\n$url');

    final response = await http.get(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json; charset=euc-kr'},
    );

    final body = response.body;
    final broken = body.substring(
      callback.length + 1, // callback( 제거
      body.length - 1, // ) 제거
    );

    // EUC-KR 디코딩
    final decode = cp949.decodeString(broken);
    final trim = trimValues(json.decode(decode));
    final paymentResponse = trim..addAll({'KSNET': '$callback($trim)'});
    logger.i(paymentResponse.toString());
    return PaymentResponse.fromJson(paymentResponse);
  }

  Future<KscatDeviceResponse> requestDeivce(String callback, String request) async {
    // URL을 직접 구성 - 인코딩 없이
    final url = '$baseUrl?callback=$callback&REQ=$request';
    logger.i('\n=== Raw KscatDevice Request URL ===\n$url');

    final response = await http.get(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json; charset=euc-kr'},
    );

    final body = response.body;
    final broken = body.substring(
      callback.length + 1, // callback( 제거
      body.length - 1, // ) 제거
    );

    // EUC-KR 디코딩
    final decode = cp949.decodeString(broken);
    final trim = trimValues(json.decode(decode));
    final kscatDeviceResponse = trim..addAll({'KSNET': '$callback($trim)'});
    logger.i(kscatDeviceResponse.toString());
    return KscatDeviceResponse.fromJson(kscatDeviceResponse);
  }

  // 모든 String 값의 공백을 trim
  Map<String, dynamic> trimValues(Map<String, dynamic> json) {
    return json.map((key, value) {
      if (value is String) {
        return MapEntry(key, value.trim());
      }
      return MapEntry(key, value);
    });
  }
}
