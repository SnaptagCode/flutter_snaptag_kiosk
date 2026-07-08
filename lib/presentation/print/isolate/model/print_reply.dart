import 'package:flutter_snaptag_kiosk/core/services/printer/models/printer_log.dart';

class PrintReply {
  PrinterLog? printerLog;
  String errorMsg = '';

  PrintReply({
    errorMsg = '',
    required this.printerLog,
  });
}
