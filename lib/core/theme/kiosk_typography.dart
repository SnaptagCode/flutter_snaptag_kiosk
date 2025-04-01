import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_snaptag_kiosk/core/theme/kiosk_colors.dart';

class KioskTypography extends ThemeExtension<KioskTypography> {
  const KioskTypography({
    required this.kioskBtn1B,
    required this.kioskBody1B,
    required this.kioskBody2B,
    required this.kioksNum1SB,
    required this.kioskNum2B,
    required this.kioskAlert1B,
    required this.kioskAlert2M,
    required this.kioskAlertBtnB,
    required this.kioskInput1B,
    required this.kioskInput2B,
    required this.kioskInput3B,
  });

  final TextStyle kioskBtn1B;
  final TextStyle kioskBody1B;
  final TextStyle kioskBody2B;
  final TextStyle kioksNum1SB;
  final TextStyle kioskNum2B;
  final TextStyle kioskAlert1B;
  final TextStyle kioskAlert2M;
  final TextStyle kioskAlertBtnB;
  final TextStyle kioskInput1B;
  final TextStyle kioskInput2B;
  final TextStyle kioskInput3B;

  factory KioskTypography.color({KioskColors colors = KioskColors.basic}) => KioskTypography(
        kioskBtn1B: TextStyle(
          fontSize: 34.sp,
          fontWeight: FontWeight.w700,
          color: Colors.black,
          letterSpacing: -0.34,
          height: 1.0,
        ),
        kioskBody1B: TextStyle(
          fontSize: 32.sp,
          fontWeight: FontWeight.w600,
          color: colors.textColor,
          letterSpacing: -0.64,
          height: 1.0,
        ),
        kioskBody2B: TextStyle(
          fontSize: 26.sp,
          fontWeight: FontWeight.w600,
          color: colors.textColor,
          letterSpacing: -0.52,
          height: 1.0,
        ),
        kioksNum1SB: TextStyle(
          fontSize: 54.sp,
          fontWeight: FontWeight.w600,
          color: Colors.black,
          letterSpacing: 0,
          height: 1.0,
        ),
        kioskNum2B: TextStyle( //키패드의 완료버튼
          //fontSize: 42.sp,
          fontSize: 38.sp,
          fontWeight: FontWeight.w700,
          color: Colors.black,
          letterSpacing: -0.42,
          height: 1.0,
        ),
        kioskAlert1B: TextStyle(
          fontSize: 42.sp,
          fontWeight: FontWeight.w700,
          color: Colors.black,
          letterSpacing: 0.84,
          height: 1.0,
        ),
        kioskAlert2M: TextStyle(
          fontSize: 28.sp,
          fontWeight: FontWeight.w500,
          color: Colors.black,
          letterSpacing: 0.56,
          height: 1.4,
        ),
        kioskAlertBtnB: TextStyle(
          fontSize: 34.sp,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: -0.34,
          height: 1.0,
        ),
        kioskInput1B: TextStyle(
          fontSize: 42.sp,
          fontWeight: FontWeight.w700,
          color: Colors.black,
          letterSpacing: 10,
          height: 1.0,
        ),
        kioskInput2B: TextStyle(
          fontSize: 40.sp,
          fontWeight: FontWeight.w700,
          color: Colors.black,
          letterSpacing: -0.4,
        ),
        kioskInput3B: TextStyle(
          fontSize: 30.sp,
          fontWeight: FontWeight.w700,
          color: Colors.black,
          letterSpacing: -0.3,
          height: 1.0,
        ),
      );

  @override
  KioskTypography copyWith({
    TextStyle? kioskBtn1B,
    TextStyle? kioskBody1B,
    TextStyle? kioskBody2B,
    TextStyle? kioksNum1SB,
    TextStyle? kioskNum2B,
    TextStyle? kioskAlert1B,
    TextStyle? kioskAlert2M,
    TextStyle? kioskAlertBtnB,
    TextStyle? kioskInput1B,
    TextStyle? kioskInput2B,
    TextStyle? kioskInput3B,
  }) {
    return KioskTypography(
      kioskBtn1B: kioskBtn1B ?? this.kioskBtn1B,
      kioskBody1B: kioskBody1B ?? this.kioskBody1B,
      kioskBody2B: kioskBody2B ?? this.kioskBody2B,
      kioksNum1SB: kioksNum1SB ?? this.kioksNum1SB,
      kioskNum2B: kioskNum2B ?? this.kioskNum2B,
      kioskAlert1B: kioskAlert1B ?? this.kioskAlert1B,
      kioskAlert2M: kioskAlert2M ?? this.kioskAlert2M,
      kioskAlertBtnB: kioskAlertBtnB ?? this.kioskAlertBtnB,
      kioskInput1B: kioskInput1B ?? this.kioskInput1B,
      kioskInput2B: kioskInput2B ?? this.kioskInput2B,
      kioskInput3B: kioskInput3B ?? this.kioskInput3B,
    );
  }

  @override
  ThemeExtension<KioskTypography> lerp(
    covariant ThemeExtension<KioskTypography>? other,
    double t,
  ) {
    if (other is! KioskTypography) {
      return this;
    }

    return KioskTypography(
      kioskBtn1B: TextStyle.lerp(kioskBtn1B, other.kioskBtn1B, t)!,
      kioskBody1B: TextStyle.lerp(kioskBody1B, other.kioskBody1B, t)!,
      kioskBody2B: TextStyle.lerp(kioskBody2B, other.kioskBody2B, t)!,
      kioksNum1SB: TextStyle.lerp(kioksNum1SB, other.kioksNum1SB, t)!,
      kioskNum2B: TextStyle.lerp(kioskNum2B, other.kioskNum2B, t)!,
      kioskAlert1B: TextStyle.lerp(kioskAlert1B, other.kioskAlert1B, t)!,
      kioskAlert2M: TextStyle.lerp(kioskAlert2M, other.kioskAlert2M, t)!,
      kioskAlertBtnB: TextStyle.lerp(kioskAlertBtnB, other.kioskAlertBtnB, t)!,
      kioskInput1B: TextStyle.lerp(kioskInput1B, other.kioskInput1B, t)!,
      kioskInput2B: TextStyle.lerp(kioskInput2B, other.kioskInput2B, t)!,
      kioskInput3B: TextStyle.lerp(kioskInput3B, other.kioskInput3B, t)!,
    );
  }
}
