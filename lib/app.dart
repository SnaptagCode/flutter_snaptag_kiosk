import 'dart:io';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:flutter_snaptag_kiosk/presentation/move_me/providers/alert_definition_provider.dart';
import 'package:flutter_snaptag_kiosk/presentation/move_me/widgets/dialog_helper.dart';
import 'package:flutter_snaptag_kiosk/presentation/move_me/widgets/general_error_widget.dart';
import 'package:window_manager/window_manager.dart';

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> with WindowListener {
  bool _initializedFullScreen = false;
  bool _hasInitializedKioskInfo = false;

  @override
  void initState() {
    super.initState();
    if (Platform.isWindows) {
      windowManager.addListener(this);
      _ensureFullScreenOnce();
    }

    // 앱 실행과 동시에 KioskInfo 미리 로드
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_hasInitializedKioskInfo) return;
      _hasInitializedKioskInfo = true;

      // 네트워크 에러 처리 함수
      Future<bool> handleNetworkError(dynamic error) async {
        // DioException 또는 네트워크 관련 에러인지 확인
        final isNetworkError = error is DioException &&
            (error.type == DioExceptionType.connectionTimeout ||
                error.type == DioExceptionType.receiveTimeout ||
                error.type == DioExceptionType.sendTimeout ||
                error.type == DioExceptionType.connectionError ||
                error.type == DioExceptionType.unknown);

        if (isNetworkError && mounted) {
          final result = await DialogHelper.showSetupOneButtonDialog(
            context,
            title: '네트워크 연결이 불안정합니다.',
            confirmButtonText: '확인',
          );
          if (result && mounted) {
            // 확인 버튼 클릭 시 앱 종료
            exit(0);
          }
          return true;
        }
        return false;
      }

      // Alert Definition 로드
      try {
        await ref.read(alertDefinitionProvider.notifier).load();
      } catch (error) {
        final handled = await handleNetworkError(error);
        if (handled) return;
        // 네트워크 에러가 아니면 로그만 남김
        SlackLogService().sendErrorLogToSlack('Alert definition load failed: $error');
      }

      // 이미 데이터가 있으면 API 호출하지 않음
      final currentInfo = ref.read(kioskInfoServiceProvider);
      if (currentInfo == null) {
        try {
          await ref.read(kioskInfoServiceProvider.notifier).getKioskMachineInfo();
        } catch (error) {
          final handled = await handleNetworkError(error);
          if (handled) return;
          // 네트워크 에러가 아니면 로그만 남김
          // 네트워크 에러 처리는 setup_main_screen에서 수행
          SlackLogService().sendErrorLogToSlack('Kiosk info load failed at app startup: $error');
        }
      }
    });
  }

  @override
  void dispose() {
    if (Platform.isWindows) {
      windowManager.removeListener(this);
    }
    super.dispose();
  }

  Future<void> _ensureFullScreenOnce() async {
    if (_initializedFullScreen) return;
    _initializedFullScreen = true;

    if (Platform.isWindows) {
      WindowOptions windowOptions = WindowOptions(
        // fullScreen: true,
        backgroundColor: Colors.transparent,
        skipTaskbar: false,
        titleBarStyle: TitleBarStyle.hidden,
      );
      await windowManager.waitUntilReadyToShow(windowOptions, () async {
        // await windowManager.setFullScreen(true);
        await windowManager.show();
      });
    }
  }

  @override
  void onWindowFocus() {
    // 포커스를 받을 때마다 fullscreen 보장
    // windowManager.setFullScreen(true);
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final theme = ref.watch(themeNotifierProvider);
    return theme.when(
      data: (themeData) => MaterialApp.router(
        debugShowCheckedModeBanner: false,
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        themeMode: ThemeMode.light,
        theme: themeData.copyWith(
          //XXX : 삭제 금지 - extensions를 추가로 등록해주지 않으면 themeNotifierProvider영역에서 등록된 extensions는 누락됨
          extensions: [
            ref.watch(kioskColorsNotifierProvider),
            KioskTypography.color(
              colors: ref.watch(kioskColorsNotifierProvider),
            ),
          ],
        ),
        routerConfig: router,
        scrollBehavior: const MaterialScrollBehavior().copyWith(
          scrollbars: false,
          dragDevices: {
            PointerDeviceKind.mouse,
            PointerDeviceKind.touch,
          },
        ),
        builder: (context, child) {
          return _flavorBanner(
            child: child!,
            ref: ref,
            show: F.appFlavor == Flavor.dev,
          );
        },
      ),
      loading: () => const _LoadingApp(),
      error: (error, stack) => _ErrorApp(error: error),
    );
  }

  Widget _flavorBanner({
    required Widget child,
    required WidgetRef ref,
    bool show = true,
  }) =>
      show
          ? Banner(
              location: BannerLocation.bottomStart,
              message: F.name,
              color: Colors.green.withOpacity(0.6),
              textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.0, letterSpacing: 1.0),
              child: child,
            )
          : Container(
              child: child,
            );
}

class _LoadingApp extends StatelessWidget {
  const _LoadingApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}

class _ErrorApp extends ConsumerWidget {
  const _ErrorApp({required this.error});
  final Object error;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Builder(builder: (context) {
            return GeneralErrorWidget(
              exception: error as Exception,
              onRetry: () => ref.refresh(kioskInfoServiceProvider),
            );
          }),
        ),
      ),
    );
  }
}
