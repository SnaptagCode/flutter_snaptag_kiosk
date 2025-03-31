import 'dart:isolate';

import 'package:flutter_snaptag_kiosk/features/core/printer/print_path.dart';

class PrintMessage {
  bool shouldPrintLog;
  PrintPath printPath;
  SendPort sendPort;

  PrintMessage({this.shouldPrintLog = false, required this.printPath, required this.sendPort});
}
