import 'package:flutter_snaptag_kiosk/presentation/setup/main/notifiers/page_print_notifier.dart';

enum SetupValidationResult { ok, noPrintTypeSelected, noKioskInfo }

class SetupValidationService {
  SetupValidationResult validateEventStart({
    required PagePrintType printType,
    required int kioskMachineId,
    required int kioskEventId,
  }) {
    if (printType == PagePrintType.none) {
      return SetupValidationResult.noPrintTypeSelected;
    }
    if (kioskMachineId == 0 || kioskEventId == 0) {
      return SetupValidationResult.noKioskInfo;
    }
    return SetupValidationResult.ok;
  }
}
