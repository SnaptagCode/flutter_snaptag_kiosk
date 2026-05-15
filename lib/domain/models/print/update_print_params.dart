import 'package:flutter_snaptag_kiosk/domain/models/enums/printed_status.dart';

class UpdatePrintParams {
  final int kioskMachineId;
  final int kioskEventId;
  final PrintedStatus status;

  const UpdatePrintParams({
    required this.kioskMachineId,
    required this.kioskEventId,
    required this.status,
  });
}
