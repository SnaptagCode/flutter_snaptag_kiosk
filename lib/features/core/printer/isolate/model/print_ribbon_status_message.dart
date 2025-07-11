import 'dart:isolate';

class PrintRibbonStatusMessage {
  SendPort sendPort;
  String errorMsg = '';

  PrintRibbonStatusMessage({
    this.errorMsg = '',
    required this.sendPort,
  });
}
