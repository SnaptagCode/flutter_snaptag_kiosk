import 'dart:async';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:window_manager/window_manager.dart';

void main() {
  if (kDebugMode) {
    F.appFlavor = Flavor.dev;
  } else {
    F.appFlavor = Flavor.prod;
  }

  // Zone으로 감싸서 모든 비동기 에러도 캐치
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await windowManagerSetting();

      final yamlStorage = await YamlStorageService.initialize();
      final imageStorage = await ImageStorageService.initialize();

      await EasyLocalization.ensureInitialized();
      FileLogger.initialize('');
      runApp(
        EasyLocalization(
          supportedLocales: const [
            Locale('ko', 'KR'),
            Locale('en', 'US'),
            Locale('ja', 'JP'),
            Locale('zh', 'CN'),
          ],
          path: 'assets/lang',
          fallbackLocale: const Locale('ko', 'KR'),
          child: ProviderScope(
            // observers: [RiverpodLogger()],
            overrides: [
              storageServiceProvider.overrideWithValue(yamlStorage),
              imageStorageProvider.overrideWithValue(imageStorage),
            ],
            child: ScreenUtilInit(
              designSize: const Size(1080, 1920),
              minTextAdapt: true,
              splitScreenMode: true,
              child: App(),
            ),
          ),
        ),
      );
    },
    (error, stack) {
      String msg = "ZONED_ERROR : $error\n$stack";
      FileLogger.severe(msg);
    },
  );
}

Future<void> windowManagerSetting() async {
  //platform이 windows인 경우에만 실행
  if (Platform.isWindows) {
    await windowManager.ensureInitialized();
    WindowOptions windowOptions = WindowOptions(
      fullScreen: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.hidden,
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.setFullScreen(true);
      await windowManager.show();
      await windowManager.focus();
    });
  }
}
