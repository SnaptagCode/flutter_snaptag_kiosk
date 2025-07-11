import 'dart:isolate';

class PrintStateMessage {
  SendPort sendPort;

  PrintStateMessage({
    required this.sendPort,
  });
}
