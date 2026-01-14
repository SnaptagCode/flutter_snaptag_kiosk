import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_snaptag_kiosk/core/extensions/extensions.dart';
import 'package:easy_localization/easy_localization.dart';

extension ButtonStyles on BuildContext {
  ButtonStyle get setupDialogCancelButtonStyle => OutlinedButton.styleFrom(
        fixedSize: Size(double.infinity, 94.h),
        minimumSize: Size(283.w, 78.h),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        elevation: 10,
        shadowColor: Colors.black.withOpacity(0.4),
        textStyle: locale.languageCode == 'ja'
            ? typography.kioskAlertBtnB.copyWith(fontFamily: 'MPLUSRounded')
            : typography.kioskAlertBtnB.copyWith(fontFamily: 'Cafe24Ssurround2'),
      );
  ButtonStyle get setupDialogConfirmButtonStyle => OutlinedButton.styleFrom(
        fixedSize: Size(double.infinity, 94.h),
        minimumSize: Size(283.w, 78.h),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        elevation: 10,
        shadowColor: Colors.black.withOpacity(0.4),
        //textStyle: typography.kioskAlertBtnB
        textStyle: locale.languageCode == 'ja'
            ? typography.kioskAlertBtnB.copyWith(fontFamily: 'MPLUSRounded')
            : typography.kioskAlertBtnB.copyWith(fontFamily: 'Cafe24Ssurround2'),
      );

  ButtonStyle get recommendedImageButtonStyle => OutlinedButton.styleFrom(
        fixedSize: Size(282.w, 67.h),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 23.5.w, vertical: 18.5.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
        elevation: 10,
        shadowColor: Colors.black.withOpacity(0.4),
      );

  ButtonStyle get refundDialogCancelButtonStyle => OutlinedButton.styleFrom(
      fixedSize: Size(double.infinity, 94.h),
      minimumSize: Size(283.w, 78.h),
      backgroundColor: Colors.white,
      //foregroundColor: kioskColors.popupButtonColor,
      foregroundColor: Color(0xFF999999),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      elevation: 10,
      shadowColor: Colors.black.withOpacity(0.4),
      textStyle: locale.languageCode == 'ja'
          ? typography.kioskAlertBtnB.copyWith(fontFamily: 'MPLUSRounded')
          : typography.kioskAlertBtnB.copyWith(fontFamily: 'Cafe24Ssurround2'),
      side: BorderSide(
        //color: kioskColors.popupButtonColor,
        color: Color(0xFF999999),
        width: 2.0,
      ));
  ButtonStyle get refundDialogConfirmButtonStyle => OutlinedButton.styleFrom(
      fixedSize: Size(double.infinity, 94.h),
      minimumSize: Size(283.w, 78.h),
      //backgroundColor: kioskColors.popupButtonColor,
      backgroundColor: Color(0xFF0080FF),
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      elevation: 10,
      shadowColor: Colors.black.withOpacity(0.4),
      //textStyle: typography.kioskAlertBtnB
      textStyle: locale.languageCode == 'ja'
          ? typography.kioskAlertBtnB.copyWith(fontFamily: 'MPLUSRounded')
          : typography.kioskAlertBtnB.copyWith(fontFamily: 'Cafe24Ssurround2'),
      side: BorderSide(
        //color: kioskColors.popupButtonColor,
        color: Color(0xFF0080FF),
        width: 2.0,
      ));

  ///
  /// [Figma](https://www.figma.com/design/8IDM2KJtqAYWm2IsmytU5W/%ED%82%A4%EC%98%A4%EC%8A%A4%ED%81%AC_%EB%94%94%EC%9E%90%EC%9D%B8_%EA%B3%B5%EC%9C%A0%EC%9A%A9?node-id=1486-15887&m=dev)
  /// - `backgroundColor` : kioskColors.buttonColor
  /// - `foregroundColor` : kioskColors.buttonTextColor
  ///
  ButtonStyle get mainLargeButtonStyle => ElevatedButton.styleFrom(
        //padding: EdgeInsets.fromLTRB(0.r, 24.r, 0.r, 0.r),
        padding: EdgeInsets.only(top: 4.5.h),
        fixedSize: Size(double.infinity, 82.h),
        minimumSize: Size(520.w, 78.h),
        backgroundColor: kioskColors.buttonColor,
        foregroundColor: kioskColors.buttonTextColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        elevation: 10,
        shadowColor: Colors.black.withOpacity(0.4),
        //textStyle: typography.kioskBtn1B.copyWith(fontFamily: 'Cafe24Ssurround2')
        //textStyle: typography.kioskBtn1B
        textStyle: locale.languageCode == 'ja'
            ? typography.kioskAlertBtnB.copyWith(fontFamily: 'MPLUSRounded')
            : typography.kioskAlertBtnB.copyWith(fontFamily: 'Cafe24Ssurround2'),
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
        //textStyle: typography.kioskAlertBtnB.copyWith(fontFamily: 'Cafe24Ssurround2')
        //textStyle: typography.kioskAlertBtnB
        textStyle: locale.languageCode == 'ja'
            ? typography.kioskAlertBtnB.copyWith(fontFamily: 'MPLUSRounded')
            : typography.kioskAlertBtnB.copyWith(fontFamily: 'Cafe24Ssurround2'),
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
        //padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 8.w),
        padding: EdgeInsets.fromLTRB(8.w, 9.h, 8.w, 6.h),
        elevation: 10,
        shadowColor: Colors.black.withOpacity(0.4),
        //textStyle: typography.kioskBtn1B.copyWith(fontFamily: 'Cafe24Ssurround2')
        //textStyle: typography.kioskBtn1B
        textStyle: locale.languageCode == 'ja'
            ? typography.kioskAlertBtnB.copyWith(fontFamily: 'MPLUSRounded')
            : typography.kioskAlertBtnB.copyWith(fontFamily: 'Cafe24Ssurround2'),
      );

  ///
  /// [Figma](https://www.figma.com/design/8IDM2KJtqAYWm2IsmytU5W/%ED%82%A4%EC%98%A4%EC%8A%A4%ED%81%AC_%EB%94%94%EC%9E%90%EC%9D%B8_%EA%B3%B5%EC%9C%A0%EC%9A%A9?node-id=931-13722&m=dev)
  /// - `backgroundColor` : kioskColors.keypadButtonColor
  /// - `foregroundColor` : #FFFFFF (고정 값)
  ///
  ButtonStyle get keypadNumberStyle => ElevatedButton.styleFrom(
        fixedSize: Size(130.w, 90.h),
        //padding: EdgeInsets.all(10.r),
        //padding: EdgeInsets.fromLTRB(10.r, 21.r, 10.r, 10.r),
        padding: EdgeInsets.fromLTRB(10.r, 18.r, 10.r, 2.r),
        backgroundColor: kioskColors.keypadButtonColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
            side: BorderSide(
              width: 1.w,
              color: kioskColors.buttonColor,
            )),
        //textStyle: typography.kioksNum1SB
        //textStyle: typography.kioksNum1SB.copyWith(fontFamily: 'Cafe24Ssurround2')
        //textStyle: typography.kioksNum1SB
        textStyle: locale.languageCode == 'ja'
            ? typography.kioksNum1SB.copyWith(fontFamily: 'MPLUSRounded')
            : typography.kioksNum1SB.copyWith(fontFamily: 'Cafe24Ssurround2'),
      );

  ButtonStyle get keypadBackStyle => ElevatedButton.styleFrom(
        fixedSize: Size(130.w, 90.h),
        padding: EdgeInsets.all(10.r),
        backgroundColor: kioskColors.keypadButtonColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
            side: BorderSide(
              width: 1.w,
              color: kioskColors.buttonColor,
            )),
        //textStyle: typography.kioksNum1SB
        //textStyle: typography.kioksNum1SB.copyWith(fontFamily: 'Cafe24Ssurround2')
        //textStyle: typography.kioksNum1SB
        textStyle: locale.languageCode == 'ja'
            ? typography.kioksNum1SB.copyWith(fontFamily: 'MPLUSRounded')
            : typography.kioksNum1SB.copyWith(fontFamily: 'Cafe24Ssurround2'),
      );

  ///
  /// [Figma](https://www.figma.com/design/8IDM2KJtqAYWm2IsmytU5W/%ED%82%A4%EC%98%A4%EC%8A%A4%ED%81%AC_%EB%94%94%EC%9E%90%EC%9D%B8_%EA%B3%B5%EC%9C%A0%EC%9A%A9?node-id=931-13744&m=dev)
  /// - `backgroundColor` : kioskColors.buttonColor
  /// - `foregroundColor` : kioskColors.buttonTextColor
  ///
  ButtonStyle get keypadCompleteStyle => ElevatedButton.styleFrom(
        fixedSize: Size(130.w, 90.h),
        //padding: EdgeInsets.only(left: 6.w, right: 6.w, top: 24.h, bottom: 24.h),
        padding: EdgeInsets.fromLTRB(10.w, 14.w, 10.h, 3.h),
        backgroundColor: kioskColors.buttonColor,
        foregroundColor: kioskColors.buttonTextColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
        //textStyle: typography.kioskNum2B.copyWith(fontFamily: 'Cafe24Ssurround2')
        //textStyle: typography.kioskNum2B
        textStyle: locale.languageCode == 'ja'
            ? typography.kioskNum2B.copyWith(fontFamily: 'MPLUSRounded')
            : typography.kioskNum2B.copyWith(fontFamily: 'Cafe24Ssurround2'),
      );
}
