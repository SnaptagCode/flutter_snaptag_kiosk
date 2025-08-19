import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_snaptag_kiosk/features/core/printer/printer_log.dart';

class PrinterLogNotifier extends Notifier<PrinterLog?> {
  @override
  PrinterLog? build() => null;

  void update(PrinterLog log) {
    state = log;
  }

  void clear() {
    state = null;
  }

  bool get hasLog => state != null;
}

final printerLogProvider =
NotifierProvider<PrinterLogNotifier, PrinterLog?>(
  PrinterLogNotifier.new,
);