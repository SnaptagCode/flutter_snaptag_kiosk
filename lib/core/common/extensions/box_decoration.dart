import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_snaptag_kiosk/core/common/extensions/extensions.dart';

extension BoxDecorationExtensions on BuildContext {
  BoxDecoration get priceBoxDecoration => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          width: 2.w,
          color: kioskColors.buttonColor,
        ),
      );
  BoxDecoration get keypadDisplayDecoration => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          width: 2.w,
          color: kioskColors.buttonColor,
        ),
      );
}
