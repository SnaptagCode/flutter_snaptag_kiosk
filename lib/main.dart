import 'dart:async';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  if (kDebugMode) {
    F.appFlavor = Flavor.dev;
  } else {
    F.appFlavor = Flavor.prod;
  }
  await dotenv.load(fileName: "assets/.env");
  final slackCall = SlackLogService();

  // Zone으로 감싸서 모든 비동기 에러도 캐치
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await windowManagerSetting();
      // ✅ FlutterError 로그 자동 감지
      FlutterError.onError = (FlutterErrorDetails details) {
        slackCall.sendLogToSlack("[FLUTTER ERROR] ${details.exceptionAsString()}");
      };

      final imageStorage = await ImageStorageService.initialize();

      await EasyLocalization.ensureInitialized();

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
            overrides: [
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
    (error, stackTrace) {
      slackCall.sendLogToSlack("[ZONE ERROR] $error\nStackTrace: $stackTrace");
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
