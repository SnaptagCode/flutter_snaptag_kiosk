import 'dart:isolate';

class ConnectMessage {
  SendPort sendPort;

  ConnectMessage({
    required this.sendPort,
  });
}
