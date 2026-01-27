import 'dart:isolate';

abstract class HasSendPort {
  SendPort get sendPort;
  set sendPort(SendPort port);
}
