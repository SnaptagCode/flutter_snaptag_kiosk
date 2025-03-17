import 'package:flutter_snaptag_kiosk/features/core/printer/printer_status.dart';
import 'package:flutter_snaptag_kiosk/features/core/printer/ribbon_status.dart';

class PrinterLog {
  PrinterStatus? printerStatus;
  RibbonStatus? ribbonStatus;
  bool? isPrintingNow;
  bool? isFeederEmpty;
  String? errorMsg;

  PrinterLog.init();

  PrinterLog(this.printerStatus, this.ribbonStatus, this.isFeederEmpty, this.isPrintingNow, this.errorMsg);
}
