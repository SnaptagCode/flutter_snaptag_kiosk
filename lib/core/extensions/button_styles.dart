import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_snaptag_kiosk/core/extensions/extensions.dart';

extension ButtonStyles on BuildContext {
  ///
  /// [Figma](https://www.figma.com/design/8IDM2KJtqAYWm2IsmytU5W/%ED%82%A4%EC%98%A4%EC%8A%A4%ED%81%AC_%EB%94%94%EC%9E%90%EC%9D%B8_%EA%B3%B5%EC%9C%A0%EC%9A%A9?node-id=1486-15887&m=dev)
  /// - `backgroundColor` : kioskColors.buttonColor
  /// - `foregroundColor` : kioskColors.buttonTextColor
  ///
  ButtonStyle get mainLargeButtonStyle => ElevatedButton.styleFrom(
        fixedSize: Size(double.infinity, 82.h),
        minimumSize: Size(520.w, 78.h),
        backgroundColor: kioskColors.buttonColor,
        foregroundColor: kioskColors.buttonTextColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        elevation: 10,
        shadowColor: Colors.black.withOpacity(0.4),
        textStyle: typography.kioskBtn1B,
      );

  ///
  /// [Figma](https://www.figma.com/design/8IDM2KJtqAYWm2IsmytU5W/%ED%82%A4%EC%98%A4%EC%8A%A4%ED%81%AC_%EB%94%94%EC%9E%90%EC%9D%B8_%EA%B3%B5%EC%9C%A0%EC%9A%A9?node-id=943-15372&m=dev)
  /// - `backgroundColor` : kioskColors.popupButtonColor
  /// - `foregroundColor` : #FFFFFF (고정 값)
  ///
  ButtonStyle get dialogButtonStyle => ElevatedButton.styleFrom(
        fixedSize: Size(double.infinity, 82.h),
        minimumSize: Size(520.w, 78.h),
        backgroundColor: kioskColors.popupButtonColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        elevation: 10,
        shadowColor: Colors.black.withOpacity(0.4),
        textStyle: typography.kioskAlertBtnB,
      );

  ///
  /// [Figma](https://www.figma.com/design/8IDM2KJtqAYWm2IsmytU5W/%ED%82%A4%EC%98%A4%EC%8A%A4%ED%81%AC_%EB%94%94%EC%9E%90%EC%9D%B8_%EA%B3%B5%EC%9C%A0%EC%9A%A9?node-id=931-13843&m=dev)
  /// - `backgroundColor` : kioskColors.buttonColor
  /// - `foregroundColor` : kioskColors.buttonTextColor
  ///
  ButtonStyle get paymentButtonStyle => ElevatedButton.styleFrom(
      fixedSize: Size(180.w, 78.h),
      backgroundColor: kioskColors.buttonColor,
      foregroundColor: kioskColors.buttonTextColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
      padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 8.w),
      elevation: 10,
      shadowColor: Colors.black.withOpacity(0.4),
      textStyle: typography.kioskBtn1B);

  ///
  /// [Figma](https://www.figma.com/design/8IDM2KJtqAYWm2IsmytU5W/%ED%82%A4%EC%98%A4%EC%8A%A4%ED%81%AC_%EB%94%94%EC%9E%90%EC%9D%B8_%EA%B3%B5%EC%9C%A0%EC%9A%A9?node-id=931-13722&m=dev)
  /// - `backgroundColor` : kioskColors.keypadButtonColor
  /// - `foregroundColor` : #FFFFFF (고정 값)
  ///
  ButtonStyle get keypadNumberStyle => ElevatedButton.styleFrom(
      fixedSize: Size(130.w, 90.h),
      padding: EdgeInsets.all(10.r),
      backgroundColor: kioskColors.keypadButtonColor,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r), side: BorderSide(width: 1.w, color: kioskColors.buttonColor)),
      textStyle: typography.kioksNum1SB);

  ///
  /// [Figma](https://www.figma.com/design/8IDM2KJtqAYWm2IsmytU5W/%ED%82%A4%EC%98%A4%EC%8A%A4%ED%81%AC_%EB%94%94%EC%9E%90%EC%9D%B8_%EA%B3%B5%EC%9C%A0%EC%9A%A9?node-id=931-13744&m=dev)
  /// - `backgroundColor` : kioskColors.buttonColor
  /// - `foregroundColor` : kioskColors.buttonTextColor
  ///
  ButtonStyle get keypadCompleteStyle => ElevatedButton.styleFrom(
      fixedSize: Size(130.w, 90.h),
      padding: EdgeInsets.only(left: 6.w, right: 6.w, top: 24.h, bottom: 24.h),
      backgroundColor: kioskColors.buttonColor,
      foregroundColor: kioskColors.buttonTextColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
      textStyle: typography.kioskNum2B);
}
