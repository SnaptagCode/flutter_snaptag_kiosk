import 'package:flutter/material.dart';

import '../theme/kiosk_colors.dart';
import '../theme/kiosk_typography.dart';

const fontFamily = 'Pretendard';

extension BuildContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);

  KioskTypography get typography => theme.extension<KioskTypography>()!;
  KioskColors get kioskColors => theme.extension<KioskColors>()!;
}
