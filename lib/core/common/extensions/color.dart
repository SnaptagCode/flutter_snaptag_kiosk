import 'package:flutter/material.dart';

extension HexColorExtension on String {
  /// HEX 문자열(#RRGGBB 또는 #AARRGGBB)을 [Color]로 변환합니다.
  /// 변환에 실패하면 [fallback]을 반환합니다. (기본값: Colors.black)
  Color toColor({Color fallback = Colors.black}) {
    if (isEmpty) return fallback;
    try {
      final hex = replaceFirst('#', '');
      final value = int.parse(hex.length == 6 ? 'ff$hex' : hex, radix: 16);
      return Color(value);
    } catch (_) {
      return fallback;
    }
  }
}
