// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:convert';

import 'package:flutter_snaptag_kiosk/features/shared/payment/data/models/payment_response.dart';

void main() {
  String jsonString = '{"MSG" : "오류            시간 초과       ", "REQ" : "AP", "RES" : "1004"}';

  print(PaymentResponse.fromJson(json.decode(jsonString)));
}
