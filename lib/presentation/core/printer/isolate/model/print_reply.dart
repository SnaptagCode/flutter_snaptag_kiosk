import 'package:flutter_snaptag_kiosk/presentation/core/printer/printer_log.dart';

class PrintReply {
  PrinterLog? printerLog;
  String errorMsg = '';

  PrintReply({
    errorMsg = '',
    required this.printerLog,
  });
}
