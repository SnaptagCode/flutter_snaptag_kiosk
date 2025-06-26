import 'dart:isolate';

import 'package:flutter_snaptag_kiosk/features/core/printer/print_path.dart';

class PrintMessage {
  PrintPath printPath;
  SendPort sendPort;
  bool isSingleMode;

  PrintMessage({
    required this.isSingleMode,
    required this.printPath,
    required this.sendPort,
  });
}
