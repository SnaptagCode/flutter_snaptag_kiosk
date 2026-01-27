import 'package:flutter/material.dart';

import '../../ui/theme/kiosk_colors.dart';
import '../../ui/theme/kiosk_typography.dart';

//const fontFamily = 'Pretendard';
//const fontFamily = 'Cafe24Ssurround2';
//const fontFamily = 'MPLUSRounded';

extension BuildContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);

  KioskTypography get typography => theme.extension<KioskTypography>()!;
  KioskColors get kioskColors => theme.extension<KioskColors>()!;
}
