import 'dart:io';

import 'package:flutter_snaptag_kiosk/data/datasources/hardware/printer/printer_hardware_datasource.dart';
import 'package:flutter_snaptag_kiosk/domain/repositories/i_printer_repository.dart';
import 'package:flutter_snaptag_kiosk/presentation/print/luca/state/printer_log.dart';
import 'package:flutter_snaptag_kiosk/presentation/print/luca/state/ribbon_status.dart';

class PrinterRepositoryImpl implements IPrinterRepository {
  final PrinterHardwareDataSource _datasource;

  PrinterRepositoryImpl(this._datasource);

  @override
  Future<PrinterLog> executePrint({
    required File? frontFile,
    required File? embeddedFile,
    required bool isSingleMode,
    required bool isMetal,
  }) =>
      _datasource.executePrint(
        frontFile: frontFile,
        embeddedFile: embeddedFile,
        isSingleMode: isSingleMode,
        isMetal: isMetal,
      );

  @override
  Future<bool> checkConnection() => _datasource.checkConnection();

  @override
  Future<bool> checkSetting() => _datasource.checkSetting();

  @override
  Future<void> checkFeeder() => _datasource.checkFeeder();

  @override
  Future<RibbonStatus> getRibbonStatus() => _datasource.getRibbonStatus();

  @override
  Future<PrinterLog> getStateLog() => _datasource.getStateLog();
}
