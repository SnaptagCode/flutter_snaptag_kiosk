import 'package:flutter/material.dart';
import 'package:flutter_snaptag_kiosk/presentation/move_me/providers/currentFontFamilyProvider.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'theme_provider.g.dart';

@riverpod
class ThemeNotifier extends _$ThemeNotifier {
  @override
  Future<ThemeData> build() async {
    ColorScheme colorScheme = _handleColorSelect(Colors.deepPurple);
    try {
      final kioskColors = ref.watch(kioskColorsNotifierProvider);
      colorScheme = _handleColorSelect(kioskColors.buttonColor);
    } catch (e) {
      colorScheme = _handleColorSelect(Colors.deepPurple);
    }
    return ThemeData(
      //fontFamily: ref.watch(currentFontFamilyProvider),
      //fontFamily: fontFamily,
      colorScheme: colorScheme,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        foregroundColor: Colors.black,
        shadowColor: Colors.black.withOpacity(.5),
        elevation: 6,
        titleTextStyle: KioskTypography.color().kioskInput2B,
      ),
    );
  }

  // ColorScheme 생성 메서드
  ColorScheme _handleColorSelect(Color value) {
    return ColorScheme.fromSeed(seedColor: value);
  }

  // 기본 테마 생성 메서드
}
