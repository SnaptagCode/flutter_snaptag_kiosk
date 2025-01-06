import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';

extension ButtonStyles on BuildContext {
  ButtonStyle get mainLargeButtonStyle => ElevatedButton.styleFrom(
        fixedSize: Size(double.infinity, 82.h),
        minimumSize: Size(520.w, 78.h),
        backgroundColor: kioskColors.buttonColor,
        foregroundColor: kioskColors.couponTextColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        elevation: 10,
        shadowColor: Colors.black.withOpacity(0.4),
        textStyle: typography.kioskBtn1B,
      );

  ButtonStyle get dialogButtonStyle => ElevatedButton.styleFrom(
        fixedSize: Size(double.infinity, 82.h),
        minimumSize: Size(520.w, 78.h),
        backgroundColor: kioskColors.buttonColor,
        foregroundColor: kioskColors.couponTextColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        elevation: 10,
        shadowColor: Colors.black.withOpacity(0.4),
        textStyle: typography.kioskAlertBtnB,
      );

  ButtonStyle get paymentButtonStyle => ElevatedButton.styleFrom(
      fixedSize: Size(180.w, 78.h),
      backgroundColor: kioskColors.buttonColor,
      foregroundColor: kioskColors.couponTextColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
      padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 8.w),
      elevation: 10,
      shadowColor: Colors.black.withOpacity(0.4),
      textStyle: typography.kioskBtn1B);

  ButtonStyle get keypadNumberStyle => ElevatedButton.styleFrom(
      fixedSize: Size(130.w, 90.h),
      padding: EdgeInsets.all(10.r),
      backgroundColor: kioskColors.keypadButtonColor,
      foregroundColor: kioskColors.couponTextColor,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r), side: BorderSide(width: 1.w, color: kioskColors.buttonColor)),
      textStyle: typography.kioksNum1SB);

  ButtonStyle get keypadCompleteStyle => ElevatedButton.styleFrom(
      fixedSize: Size(130.w, 90.h),
      padding: EdgeInsets.only(left: 6.w, right: 6.w, top: 24.h, bottom: 24.h),
      backgroundColor: kioskColors.buttonColor,
      foregroundColor: kioskColors.couponTextColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
      textStyle: typography.kioskNum2B);
}
