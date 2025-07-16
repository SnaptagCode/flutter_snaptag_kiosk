import 'package:flutter_snaptag_kiosk/features/core/printer/print_path.dart';

class PrintMessage {
  PrintImageBuffer printPath;
  bool isSingleMode;

  PrintMessage({
    required this.isSingleMode,
    required this.printPath,
  });
}
