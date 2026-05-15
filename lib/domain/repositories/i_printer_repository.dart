import 'dart:io';

import 'package:flutter_snaptag_kiosk/presentation/print/luca/state/printer_log.dart';
import 'package:flutter_snaptag_kiosk/presentation/print/luca/state/ribbon_status.dart';

abstract interface class IPrinterRepository {
  Future<PrinterLog> executePrint({
    required File? frontFile,
    required File? embeddedFile,
    required bool isSingleMode,
    required bool isMetal,
  });

  Future<bool> checkConnection();

  Future<bool> checkSetting();

  Future<void> checkFeeder();

  Future<RibbonStatus> getRibbonStatus();

  Future<PrinterLog> getStateLog();
}
