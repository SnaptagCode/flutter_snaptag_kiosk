import 'package:flutter/material.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'theme_provider.g.dart';

@riverpod
class ThemeNotifier extends _$ThemeNotifier {
  @override
  Future<ThemeData> build() async {
    try {
      // YAML 레포지토리에서 키오스크 정보 가져오기
      final kioskInfo = ref.read(storageServiceProvider).settings;

      // 직접 테마 생성 로직 구현
      final kioskColors = _createKioskColors(kioskInfo);
      final primary = kioskColors.buttonColor;
      final colorScheme = _handleColorSelect(primary);

      return ThemeData(
        fontFamily: fontFamily,
        colorScheme: colorScheme,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          foregroundColor: Colors.black,
          shadowColor: Colors.black.withOpacity(.5),
          elevation: 6,
          titleTextStyle: KioskTypography.basic.kioskInput2B.copyWith(color: Colors.black),
        ),
        extensions: [
          kioskColors,
          KioskTypography.basic,
        ],
      );
    } catch (e) {
      // 기본 테마로 폴백
      return _createDefaultTheme();
    }
  }

  // KioskColors 생성 메서드
  KioskColors _createKioskColors(KioskMachineInfo info) {
    return KioskColors(
      buttonColor: _parseColor(info.mainButtonColor),
      buttonTextColor: _parseColor(info.buttonTextColor),
      keypadButtonColor: _parseColor(info.keyPadColor),
      couponTextColor: _parseColor(info.couponTextColor),
      textColor: _parseColor(info.mainTextColor),
      popupButtonColor: _parseColor(info.popupButtonColor),
    );
  }

  // Color 파싱 메서드
  Color _parseColor(String hexColor) {
    if (hexColor.isEmpty) return Colors.black;
    try {
      return Color(int.parse(hexColor.replaceFirst('#', '0xff')));
    } catch (e) {
      return Colors.black;
    }
  }

  // ColorScheme 생성 메서드
  ColorScheme _handleColorSelect(Color value) {
    return ColorScheme.fromSeed(seedColor: value);
  }

  // 이미지 기반 ColorScheme 생성 메서드 (필요한 경우)
  Future<ColorScheme> _handleImageSelect(String url) async {
    return await ColorScheme.fromImageProvider(provider: NetworkImage(url));
  }

  // 기본 테마 생성 메서드
  ThemeData _createDefaultTheme() {
    final defaultInfo = const KioskMachineInfo();
    final defaultColors = _createKioskColors(defaultInfo);
    final defaultScheme = _handleColorSelect(defaultColors.buttonColor);

    return ThemeData(
      fontFamily: fontFamily,
      colorScheme: defaultScheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        foregroundColor: Colors.black,
        shadowColor: Colors.black.withOpacity(.5),
        elevation: 6,
        titleTextStyle: KioskTypography.basic.kioskInput2B.copyWith(color: Colors.black),
      ),
      extensions: [
        defaultColors,
        KioskTypography.basic,
      ],
    );
  }
}
