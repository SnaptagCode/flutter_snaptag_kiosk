import 'package:flutter/material.dart';

class KioskColors extends ThemeExtension<KioskColors> {
  const KioskColors({
    required this.buttonColor,
    required this.buttonTextColor,
    required this.keypadButtonColor,
    required this.couponTextColor,
    required this.textColor,
    required this.popupButtonColor,
  });

  // 버튼/키컬러, 인증번호, 넘버 line
  final Color buttonColor;
  // 버튼 텍스트
  final Color buttonTextColor;
  // 키패드/쿠폰번호 버튼
  final Color keypadButtonColor;
  // 쿠폰번호 텍스트
  final Color couponTextColor;
  // 텍스트
  final Color textColor;
  // 팝업 버튼
  final Color popupButtonColor;

  static const basic = KioskColors(
    buttonColor: Color(0xFFD05598), // #ffffff
    buttonTextColor: Color(0xFFFFFFFF), // #1C1C1C
    keypadButtonColor: Color(0xFF232323), // #797B80
    couponTextColor: Color(0xFFFFFFFF), // #ffffff
    textColor: Color(0xFF232323), // #ADADAD
    popupButtonColor: Color(0xFFD05598), // #1C1C1C
  );

  @override
  KioskColors copyWith({
    Color? buttonColor,
    Color? buttonTextColor,
    Color? keypadButtonColor,
    Color? couponTextColor,
    Color? textColor,
    Color? popupButtonColor,
  }) {
    return KioskColors(
      buttonColor: buttonColor ?? this.buttonColor,
      buttonTextColor: buttonTextColor ?? this.buttonTextColor,
      keypadButtonColor: keypadButtonColor ?? this.keypadButtonColor,
      couponTextColor: couponTextColor ?? this.couponTextColor,
      textColor: textColor ?? this.textColor,
      popupButtonColor: popupButtonColor ?? this.popupButtonColor,
    );
  }

  @override
  ThemeExtension<KioskColors> lerp(
    covariant ThemeExtension<KioskColors>? other,
    double t,
  ) {
    if (other is! KioskColors) {
      return this;
    }

    return KioskColors(
      buttonColor: Color.lerp(buttonColor, other.buttonColor, t)!,
      buttonTextColor: Color.lerp(buttonTextColor, other.buttonTextColor, t)!,
      keypadButtonColor: Color.lerp(keypadButtonColor, other.keypadButtonColor, t)!,
      couponTextColor: Color.lerp(couponTextColor, other.couponTextColor, t)!,
      textColor: Color.lerp(textColor, other.textColor, t)!,
      popupButtonColor: Color.lerp(popupButtonColor, other.popupButtonColor, t)!,
    );
  }
}
