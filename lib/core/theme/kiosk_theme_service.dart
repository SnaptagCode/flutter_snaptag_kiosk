import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:palette_generator/palette_generator.dart';

class KioskThemeService {
  final KioskMachineInfo kioskInfo;

  KioskThemeService(this.kioskInfo);

  Future<ThemeData> createTheme() async {
    final kioskColors = _createKioskColors();
    final primary = kioskColors.buttonColor;

    Color? backgroundColor = await _extractBackgroundColor();
    if (backgroundColor != null) {
      // ColorScheme 생성
      final colorScheme = ColorScheme.fromSeed(
        seedColor: primary,
        brightness: ThemeData.estimateBrightnessForColor(backgroundColor),
        surface: backgroundColor,
      );

      return ThemeData(
        fontFamily: fontFamily,
        colorScheme: colorScheme,
        extensions: [
          kioskColors,
          KioskTypography.basic, // 기존 타이포그래피 유지
        ],
      );
    } else {
      return ThemeData(
        fontFamily: fontFamily,
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: _createMaterialColor(primary),
          accentColor: kioskColors.buttonTextColor,
          brightness: Brightness.light,
        ),
        extensions: [
          kioskColors,
          KioskTypography.basic, // 기존 타이포그래피 유지
        ],
      );
    }
  }

  KioskColors _createKioskColors() {
    return KioskColors(
      buttonColor: _parseColor(kioskInfo.mainButtonColor),
      buttonTextColor: _parseColor(kioskInfo.buttonTextColor),
      keypadButtonColor: _parseColor(kioskInfo.keyPadColor),
      couponTextColor: _parseColor(kioskInfo.couponTextColor),
      textColor: _parseColor(kioskInfo.mainTextColor),
      popupButtonColor: _parseColor(kioskInfo.popupButtonColor),
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

  MaterialColor _createMaterialColor(Color color) {
    List<double> strengths = <double>[.05];
    Map<int, Color> swatch = {};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }

    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }

    return MaterialColor(color.value, swatch);
  }

  Future<Color?> _extractBackgroundColor() async {
    try {
      Uint8List bytes = (await NetworkAssetBundle(Uri.parse(kioskInfo.mainImageUrl)).load(kioskInfo.mainImageUrl))
          .buffer
          .asUint8List();

      final ui.Image image = await decodeImageFromList(bytes);

      final PaletteGenerator paletteGenerator = await PaletteGenerator.fromImage(
        image,
        maximumColorCount: 20,
      );

      return paletteGenerator.dominantColor?.color;
    } catch (e) {
      debugPrint('Failed to extract background color: $e');
      return null;
    }
  }
}
