import 'package:flutter/foundation.dart';

enum Flavor {
  dev,
  prod,
}

class F {
  static Flavor? appFlavor;

  static String get name => appFlavor?.name ?? '';

  static String get title {
    switch (appFlavor) {
      case Flavor.dev:
        return 'snaptag(dev)';
      case Flavor.prod:
        return 'snaptag';
      default:
        return 'title';
    }
  }

  static String get adminBaseUrl {
    switch (F.appFlavor) {
      case Flavor.dev:
        return 'https://kiosk-admin-dev-server.snaptag.co.kr';
      case Flavor.prod:
        return 'https://kiosk-admin-server.snaptag.co.kr';
      default:
        return 'https://kiosk-admin-server.snaptag.co.kr';
    }
  }

  static String get kioskBaseUrl {
    switch (F.appFlavor) {
      case Flavor.dev:
        return 'https://dev-api-spring-kiosk.snaptag.co.kr';
      case Flavor.prod:
        return 'https://api-spring-kiosk.snaptag.co.kr';
      default:
        return 'https://api-spring-kiosk.snaptag.co.kr';
    }
  }

  /// JKLI-175: machine/info 응답 mock 테스트용 Postman mock URL.
  /// 로컬 디버그 테스트 시에만 URL을 기입하고, 커밋/릴리즈에는 항상 null 유지.
  /// mock: https://8a3908b8-52c9-4d1b-8e76-2163034ddb54.mock.pstmn.io
  // static const String? machineInfoMockUrl = 'https://8a3908b8-52c9-4d1b-8e76-2163034ddb54.mock.pstmn.io';
  static const String? machineInfoMockUrl = null;

  /// machine/info 계열 API가 실제 사용하는 base URL.
  /// 디버그 빌드에서 machineInfoMockUrl이 설정된 경우에만 mock으로 향한다 (나머지 API는 kioskBaseUrl 유지).
  static String get machineInfoBaseUrl {
    if (kDebugMode && machineInfoMockUrl != null) {
      return machineInfoMockUrl!;
    }
    return kioskBaseUrl;
  }

  static String get qrCodePrefix {
    switch (appFlavor) {
      case Flavor.dev:
        return 'https://dev-photocard-kiosk-qr.snaptag.co.kr';
      case Flavor.prod:
        return 'https://photocard-kiosk-qr.snaptag.co.kr';
      default:
        return 'https://photocard-kiosk-qr.snaptag.co.kr';
    }
  }
}
