import 'package:flutter_snaptag_kiosk/core/services/printer/models/printer_log.dart';

class PrintStateReply {
  PrinterLog? printerLog;
  String errorMsg = '';

  PrintStateReply({
    errorMsg = '',
    required this.printerLog,
  });
}
