import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_snaptag_kiosk/core/common/log/app_log_service.dart';
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
  AppLogService.instance.info('앱 시작');
  await dotenv.load(fileName: "assets/.env");
  final slackCall = SlackLogService();

  // Zone으로 감싸서 모든 비동기 에러도 캐치
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // WindowManager 초기화만 수행 (설정은 App에서)
      if (Platform.isWindows) {
        await windowManager.ensureInitialized();
      }

      // ✅ FlutterError 로그 자동 감지
      FlutterError.onError = (FlutterErrorDetails details) {
        slackCall.sendLogToSlack("[FLUTTER ERROR] ${details.exceptionAsString()}");
      };

      // ✅ Zone/FlutterError를 벗어난 비동기 예외 감지
      PlatformDispatcher.instance.onError = (error, stack) {
        slackCall.sendLogToSlack("[PLATFORM ERROR] $error\nStackTrace: $stack");
        return true;
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
                _checkAndReportNativeCrash(SlackLogService());
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

// C++ 크래시 핸들러가 저장한 crash_log.txt를 감지하여 Slack으로 전송
Future<void> _checkAndReportNativeCrash(SlackLogService slackCall) async {
  if (!Platform.isWindows) return;
  final exeDir = File(Platform.resolvedExecutable).parent.path;
  final crashFile = File('$exeDir/crash_log.txt');
  if (await crashFile.exists()) {
    final content = await crashFile.readAsString();
    await slackCall.sendLogToSlack("[NATIVE CRASH] 이전 실행에서 비정상 종료 감지\n$content");
    await crashFile.delete();
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
