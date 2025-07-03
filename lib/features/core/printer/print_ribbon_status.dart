import 'dart:isolate';

class PrintRibbonStatus {
  SendPort sendPort;

  PrintRibbonStatus({
    required this.sendPort,
  });
}
