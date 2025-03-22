import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_snaptag_kiosk/features/core/printer/printer_manager.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';

class PrintFunctionTestWidget extends ConsumerWidget {
  late final PrinterManager _printerIso;

  PrintFunctionTestWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(16.0),
      child: Row(
        spacing: 10,
        children: [
          ElevatedButton(
            onPressed: () async {
              _printerIso = PrinterManager();

              _printerIso.initializePrinter();

              logger.i("Printer initialization completed");
            },
            child: Text('프린트 상태 초기화'),
          ),
          ElevatedButton(
            onPressed: () async {
              _printerIso.getPrinterStatus(1);
            },
            child: Text('프린트 상태 확인'),
          ),
          ElevatedButton(
            onPressed: () async {
              _printerIso.getRbnAndFilmRemaining();
            },
            child: Text('리본 및 필름 잔량 확인'),
          ),
          ElevatedButton(
            onPressed: () async {
              _printerIso.checkCardPosition();
            },
            child: Text('카드 확인'),
          ),
          ElevatedButton(
            onPressed: () async {
              _printerIso.checkFeederStatus();
            },
            child: Text('피더 확인'),
          ),
          ElevatedButton(
            onPressed: () async {
              await ref.read(printerServiceProvider.notifier).startPrinterLogging();
            },
            child: Text('로깅'),
          ),
        ],
      ),
    );
  }
}
