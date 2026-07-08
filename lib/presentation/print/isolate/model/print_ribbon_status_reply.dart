import 'package:flutter_snaptag_kiosk/core/services/printer/models/ribbon_status.dart';

class PrintRibbonStatusReply {
  RibbonStatus? ribbonStatus;
  String errorMsg = '';

  PrintRibbonStatusReply({
    this.errorMsg = '',
    required this.ribbonStatus,
  });
}
