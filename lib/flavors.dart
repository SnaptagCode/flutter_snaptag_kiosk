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
        return 'https://kiosk-dev-server.snaptag.co.kr';
      case Flavor.prod:
        return 'https://kiosk-server.snaptag.co.kr';
      default:
        return 'https://kiosk-server.snaptag.co.kr';
    }
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
