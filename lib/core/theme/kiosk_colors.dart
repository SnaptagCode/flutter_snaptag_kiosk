import 'package:flutter/material.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'kiosk_colors.g.dart';

@riverpod
class KioskColorsNotifier extends _$KioskColorsNotifier {
  @override
  KioskColors build() {
    // theme 프로바이더를 watch
    final kiosk = ref.watch(asyncKioskInfoProvider);

    return kiosk.when(
      data: (info) {
        return KioskColors(
          buttonColor: _parseColor(info.mainButtonColor),
          buttonTextColor: _parseColor(info.buttonTextColor),
          keypadButtonColor: _parseColor(info.keyPadColor),
          couponTextColor: _parseColor(info.couponTextColor),
          textColor: _parseColor(info.mainTextColor),
          popupButtonColor: _parseColor(info.popupButtonColor),
        );
      },
      loading: () => KioskColors.basic,
      error: (_, __) => KioskColors.basic,
    );
  }

  Color _parseColor(String hexColor) {
    if (hexColor.isEmpty) return Colors.black;
    try {
      return Color(int.parse(hexColor.replaceFirst('#', '0xff')));
    } catch (e) {
      return Colors.black;
    }
  }
}

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
    buttonColor: Color.fromARGB(255, 13, 96, 32), // #ffffff
    buttonTextColor: Color(0xFFFFFFFF), // #1C1C1C
    keypadButtonColor: Color(0xFF232323), // #797B80
    couponTextColor: Color(0xFFFFFFFF), // #ffffff
    textColor: Color(0xFF232323), // #ADADAD
    popupButtonColor: Color.fromARGB(255, 13, 96, 32), // #1C1C1C
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
