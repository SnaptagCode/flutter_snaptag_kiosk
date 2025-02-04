import 'dart:convert';

import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:http/http.dart' as http;

class PaymentApiClient {
  PaymentApiClient();

  static const baseUrl = 'http://127.0.0.1:27098';

  Future<PaymentResponse> requestPayment(String callback, String request) async {
    // URL을 직접 구성 - 인코딩 없이
    final url = '$baseUrl?callback=$callback&REQ=$request';
    print('\n=== Raw Payment Request URL ===\n$url');

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
    final paymentResponse = json.decode(decode)..addAll({'ksnet': '$callback($decode)'});
    logger.d(paymentResponse);
    return PaymentResponse.fromJson(paymentResponse);
  }
}
