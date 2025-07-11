import 'dart:isolate';

class SettingPrinterMessage {
  SendPort sendPort;

  SettingPrinterMessage({
    required this.sendPort,
  });
}
