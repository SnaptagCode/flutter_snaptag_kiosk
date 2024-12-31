import 'package:flutter/material.dart';

import 'kiosk_colors.dart';
import 'kiosk_typography.dart';

const fontFamily = 'PretendardJP';

extension BuildContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);

  KioskTypography get typography => theme.extension<KioskTypography>()!;
  KioskColors get kioskColors => theme.extension<KioskColors>()!;
}
