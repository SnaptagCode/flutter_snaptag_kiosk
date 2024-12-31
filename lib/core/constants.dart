import 'package:flutter/foundation.dart';

class Constants {
  static const String adminBaseUrl =
      kDebugMode ? 'https://kiosk-admin-dev-server.snaptag.co.kr' : 'https://kiosk-admin-server.snaptag.co.kr';
  static const String kioskBaseUrl =
      kDebugMode ? 'https://kiosk-dev-server.snaptag.co.kr' : 'https://kiosk-server.snaptag.co.kr';
}
