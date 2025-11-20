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
  // 인증서 유효성 무시
  HttpOverrides.global = MyHttpOverrides();
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
            child: Builder(
              builder: (context) {
                final container = ProviderScope.containerOf(context);
                SlackLogService().init(container);
                return ScreenUtilInit(
                  designSize: const Size(1080, 1920),
                  minTextAdapt: true,
                  splitScreenMode: true,
                  child: App(),
                );
              },
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

    // waitUntilReadyToShow를 await으로 기다림 (저사양 PC 대응)
    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.setFullScreen(true);
      await windowManager.show();
      await windowManager.focus();
    });

    // 저사양 PC에서 화면 크기 인식 문제 해결을 위한 재설정
    // 전체화면 설정 후 약간의 지연을 두고 크기를 다시 확인
    await Future.delayed(Duration(milliseconds: 150));

    // 화면 크기를 다시 확인하고 필요시 재설정
    final currentSize = await windowManager.getSize();
    final bounds = await windowManager.getBounds();

    // 화면이 제대로 설정되지 않았거나 크기가 비정상적이면 다시 설정
    // 저사양 PC에서는 화면 크기 인식이 늦을 수 있음
    if (currentSize.width == 0 || currentSize.height == 0 || bounds.width == 0 || bounds.height == 0) {
      // 전체화면 해제 후 다시 설정
      await windowManager.setFullScreen(false);
      await Future.delayed(Duration(milliseconds: 100));
      await windowManager.setFullScreen(true);
      await Future.delayed(Duration(milliseconds: 50));
    }

    // 최종적으로 전체화면 재확인 및 포커스
    await windowManager.setFullScreen(true);
    await windowManager.focus();
  }
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
