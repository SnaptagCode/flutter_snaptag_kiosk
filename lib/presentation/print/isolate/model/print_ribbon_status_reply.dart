import 'package:flutter_snaptag_kiosk/presentation/print/luca/state/ribbon_status.dart';

class PrintRibbonStatusReply {
  RibbonStatus? ribbonStatus;
  String errorMsg = '';

  PrintRibbonStatusReply({
    this.errorMsg = '',
    required this.ribbonStatus,
  });
}
