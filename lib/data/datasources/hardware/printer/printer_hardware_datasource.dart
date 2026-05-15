import 'dart:io';

import 'package:flutter_snaptag_kiosk/core/common/errors/printer_exception.dart';
import 'package:flutter_snaptag_kiosk/presentation/print/isolate/printer_manager.dart';
import 'package:flutter_snaptag_kiosk/presentation/print/luca/state/printer_log.dart';
import 'package:flutter_snaptag_kiosk/presentation/print/luca/state/ribbon_status.dart';

class PrinterHardwareDataSource {
  Future<PrinterLog> executePrint({
    required File? frontFile,
    required File? embeddedFile,
    required bool isSingleMode,
    required bool isMetal,
  }) async {
    try {
      final manager = await PrinterManager.getInstance();
      final log = await manager.startPrint(
        isSingleMode: isSingleMode,
        frontFile: frontFile,
        embeddedFile: embeddedFile,
        isMetal: isMetal,
      );
      if (log == null) throw PrinterException.fromError('print returned null log');
      return log;
    } on PrinterException {
      rethrow;
    } catch (e) {
      throw PrinterException.fromError(e);
    }
  }

  Future<bool> checkConnection() async {
    try {
      final manager = await PrinterManager.getInstance();
      return await manager.checkConnectedPrint();
    } catch (e) {
      throw PrinterException.connectionFailed();
    }
  }

  Future<bool> checkSetting() async {
    try {
      final manager = await PrinterManager.getInstance();
      return await manager.checkSettingPrinter();
    } catch (e) {
      throw PrinterException.fromError(e);
    }
  }

  Future<void> checkFeeder() async {
    try {
      final manager = await PrinterManager.getInstance();
      await manager.checkFeeder();
    } on PrinterException {
      rethrow;
    } catch (e) {
      throw PrinterException.feederEmpty();
    }
  }

  Future<RibbonStatus> getRibbonStatus() async {
    try {
      final manager = await PrinterManager.getInstance();
      return await manager.getRibbonStatus();
    } catch (e) {
      throw PrinterException.fromError(e);
    }
  }

  Future<PrinterLog> getStateLog() async {
    try {
      final manager = await PrinterManager.getInstance();
      final log = await manager.startLog();
      if (log == null) throw PrinterException.fromError('state log returned null');
      return log;
    } on PrinterException {
      rethrow;
    } catch (e) {
      throw PrinterException.fromError(e);
    }
  }
}
