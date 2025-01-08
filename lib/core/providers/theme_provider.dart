import 'package:flutter/material.dart';
import 'package:flutter_snaptag_kiosk/data/data.dart';
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

      // KioskThemeService 생성
      final themeService = KioskThemeService(kioskInfo);

      return await themeService.createTheme();
    } catch (e) {
      // 기본 테마로 폴백
      return KioskThemeService(const KioskMachineInfo()).createTheme();
    }
  }
}
