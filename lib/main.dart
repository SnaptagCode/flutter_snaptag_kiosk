import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  // 인증서 유효성 무시
  HttpOverrides.global = MyHttpOverrides();
  if (kDebugMode) {
    F.appFlavor = Flavor.dev;
  } else {
    F.appFlavor = Flavor.prod;
  }
  await dotenv.load(fileName: "assets/.env");
  final slackCall = SlackLogService();

  // 모든 동기 Flutter 오류
  FlutterError.onError = (details) {
    _logAndNotify(details.exception, details.stack);
    FlutterError.presentError(details); // 개발 중엔 콘솔에도 출력
  };

  // Zone으로 감싸서 모든 비동기 에러도 캐치
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await windowManagerSetting();
      // ✅ FlutterError 로그 자동 감지
      FlutterError.onError = (FlutterErrorDetails details) {
        slackCall.sendLogToSlack("[FLUTTER ERROR] ${details.exceptionAsString()}");
      };

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

void _logAndNotify(Object error, StackTrace? stack) {
  logger.e('PRINTER-CRASH : error: $error stack: $stack'); // 파일 로그 기록
}

// 🚨 SSL 인증서 오류(HandshakeException) 해결을 위한 설정
// ➤ 신뢰할 수 없는 인증서로 인해 발생하는 HandshakeException을 방지하기 위해 인증서 검증을 무시하는 작업
// ➤ Windows IOT 버전에서 발생한 오류
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    // '?'를 추가해서 null safety 확보
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}
