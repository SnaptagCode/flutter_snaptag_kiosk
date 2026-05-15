import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_snaptag_kiosk/core/core.dart';
import 'package:flutter_snaptag_kiosk/data/data.dart';
import 'package:flutter_snaptag_kiosk/presentation/core/slack_log_provider.dart';
import 'package:flutter_snaptag_kiosk/domain/domain.dart';
import 'package:flutter_snaptag_kiosk/presentation/print/card_printer.dart';
import 'package:flutter_snaptag_kiosk/presentation/setup/front_photo_list.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'print_di.g.dart';

@riverpod
PrinterHardwareDataSource printerHardwareDataSource(Ref ref) {
  return PrinterHardwareDataSource();
}

@riverpod
IPrinterRepository printerRepository(Ref ref) {
  return PrinterRepositoryImpl(ref.watch(printerHardwareDataSourceProvider));
}

@riverpod
IKioskPrintRepository kioskPrintRepository(Ref ref) {
  return ref.watch(kioskRepositoryProvider);
}

@riverpod
PrintCardUseCase printCardUseCase(Ref ref) {
  return PrintCardUseCase(
    frontPhotoService: ref.watch(frontPhotoListProvider.notifier),
    printerService: ref.watch(printerServiceProvider.notifier),
    printRepository: ref.watch(kioskPrintRepositoryProvider),
    slackLog: ref.watch(slackLogServiceProvider),
    imageConverter: ImageHelper.instance,
  );
}
