import 'package:flutter_snaptag_kiosk/presentation/print/luca/state/printer_log.dart';

class PrintStateReply {
  PrinterLog? printerLog;
  String errorMsg = '';

  PrintStateReply({
    errorMsg = '',
    required this.printerLog,
  });
}
