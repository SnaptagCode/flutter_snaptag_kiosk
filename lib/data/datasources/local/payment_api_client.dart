import 'dart:convert';

import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:http/http.dart' as http;

class PaymentApiClient {
  PaymentApiClient();

  static const baseUrl = 'http://127.0.0.1:27098';

  Future<dynamic> requestPayment(String callback, String request) async {
    // URL을 직접 구성 - 인코딩 없이
    final url = '$baseUrl?callback=$callback&REQ=$request';
    print('\n=== Raw Payment Request URL ===\n$url');

    final response = await http.get(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
    );
    logger.d(response.body);
    // JSONP 응답 파싱
    // 응답 형식: callback('{"res":"0000","data":{...}}')
    final body = response.body;
    final jsonStr = body.substring(
      callback.length + 2, // callback( 제거
      body.length - 2, // ); 제거
    );
    logger.d(jsonStr);
    logger.d(json.decode(jsonStr));
    logger.d(PaymentResponse.fromJson(json.decode(jsonStr)));
    return PaymentResponse.fromJson(json.decode(jsonStr));
  }
}
