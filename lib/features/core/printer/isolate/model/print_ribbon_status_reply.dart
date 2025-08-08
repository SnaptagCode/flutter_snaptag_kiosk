import 'package:flutter_snaptag_kiosk/features/core/printer/ribbon_status.dart';

class PrintRibbonStatusReply {
  RibbonStatus? ribbonStatus;
  String errorMsg = '';

  PrintRibbonStatusReply({
    this.errorMsg = '',
    required this.ribbonStatus,
  });
}
