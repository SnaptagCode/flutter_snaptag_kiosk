import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_snaptag_kiosk/core/services/printer/models/print_job.dart';
import 'package:flutter_snaptag_kiosk/core/services/printer/models/printer_log.dart';
import 'package:flutter_snaptag_kiosk/core/services/printer/models/ribbon_status.dart';
import 'package:flutter_snaptag_kiosk/core/services/printer/printer_device.dart';
import 'package:flutter_snaptag_kiosk/presentation/kiosk_shell/kiosk_info_service.dart';
import 'package:flutter_snaptag_kiosk/presentation/print/isolate/printer_manager.dart';

/// LUCA(DSRetransfer600) 구현체. 기존 PrinterManager에 1:1 위임만 한다.
/// try-catch·Slack·서버 보고 등 정책은 PrinterService 책임.
class LucaPrinterDevice extends PrinterDevice {
  LucaPrinterDevice(this.ref);

  final Ref ref;

  /// machineId는 호출 시점에 lazy 조회한다 (kioskInfoServiceProvider는 sync).
  Future<PrinterManager> _manager() {
    final machineId = ref.read(kioskInfoServiceProvider)?.kioskMachineId;
    return PrinterManager.getInstance(machineId: machineId);
  }

  @override
  Future<bool> isConnected() async {
    final manager = await _manager();
    return manager.checkConnectedPrint();
  }

  @override
  Future<bool> ensureReady() async {
    final manager = await _manager();
    return manager.checkSettingPrinter();
  }

  @override
  Future<void> ensureFeederLoaded() async {
    final manager = await _manager();
    await manager.checkFeeder();
  }

  @override
  Future<RibbonStatus> ribbonStatus() async {
    final manager = await _manager();
    return manager.getRibbonStatus();
  }

  @override
  Future<PrinterLog?> readLog() async {
    final manager = await _manager();
    return manager.startLog();
  }

  @override
  Future<PrinterLog?> print(PrintJob job) async {
    final manager = await _manager();
    return manager.startPrint(
      isSingleMode: job.isSingleMode,
      frontFile: job.frontFile,
      embeddedFile: job.backFile,
      isMetal: job.isMetal,
    );
  }

  @override
  bool get supportsCacheClear => true;

  @override
  Future<void> clearCache() async {
    final manager = await _manager();
    await manager.clearLibrary();
  }
}
