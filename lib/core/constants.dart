import 'package:flutter/foundation.dart';

class Constants {
  static const String adminBaseUrl =
      kDebugMode ? 'https://kiosk-admin-dev-server.snaptag.co.kr' : 'https://kiosk-admin-server.snaptag.co.kr';
  static const String kioskBaseUrl =
      kDebugMode ? 'https://kiosk-dev-server.snaptag.co.kr' : 'https://kiosk-server.snaptag.co.kr';
}

class SnaptagImages {
  SnaptagImages._();

  static const String defaultHeader = 'assets/images/header.png';

  static const String defaultBody = 'assets/images/body.png';

  static const String arrowBack = 'assets/images/arrow_back.png';

  static const String close = 'assets/images/close.png';

  static const String printLoading = 'assets/images/print_loading.png';

  static const String iconHome = 'assets/images/icon_home.png';
}
