import 'dart:async';
import 'dart:ffi' hide Size;
import 'dart:io';
import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_snaptag_kiosk/core/ui/widget/dialog_helper.dart';
import 'package:flutter_snaptag_kiosk/core/ui/widget/general_error_widget.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:flutter_snaptag_kiosk/presentation/kiosk_shell/home_timeout_provider.dart';
import 'package:flutter_snaptag_kiosk/presentation/kiosk_shell/kiosk_info_service.dart';
import 'package:flutter_snaptag_kiosk/presentation/setup/alert_definition_provider.dart';
import 'package:go_router/go_router.dart';
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
      // 첫 프레임 이후 디스플레이 정보가 확정된 시점에 창 크기 적용
      if (Platform.isWindows) {
        await _applyWindowSize();
      }

      if (_hasInitializedKioskInfo) return;
      _hasInitializedKioskInfo = true;

      // Alert Definition 로드
      try {
        await ref.read(alertDefinitionProvider.notifier).load();
      } catch (error) {
        SlackLogService().sendErrorLogToSlack('Alert definition load failed: $error');
      }

      // 이미 데이터가 있으면 API 호출하지 않음
      final currentInfo = ref.read(kioskInfoServiceProvider);
      if (currentInfo == null) {
        try {
          await ref.read(kioskInfoServiceProvider.notifier).getKioskMachineInfo();
        } catch (error) {
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
        alwaysOnTop: true,
      );
      await windowManager.waitUntilReadyToShow(windowOptions, () async {
        await windowManager.setPosition(Offset(-6, 0.0));
        await windowManager.show();
      });
    }
  }

  /// Windows API(FFI)로 실제 화면 해상도와 DPI를 읽어 창 크기를 적용
  /// PlatformDispatcher.displays는 초기화 타이밍에 따라 0을 반환할 수 있어 FFI로 직접 조회
  Future<void> _applyWindowSize() async {
    final user32 = DynamicLibrary.open('user32.dll');

    // GetSystemMetrics: 물리 픽셀 기준 화면 크기
    final getSystemMetrics = user32.lookupFunction<Int32 Function(Int32), int Function(int)>('GetSystemMetrics');
    const smCxScreen = 0;
    const smCyScreen = 1;
    final physicalWidth = getSystemMetrics(smCxScreen).toDouble();
    final physicalHeight = getSystemMetrics(smCyScreen).toDouble();

    final logicalSize = Size(physicalWidth + 16, physicalHeight + 10);
    logger.i('App: screen=${physicalWidth}x$physicalHeight, logical=$logicalSize');

    await windowManager.setSize(logicalSize);
  }

  @override
  void onWindowFocus() {}

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
            child: _TimeoutToHomeWrapper(
              ref: ref,
              child: _NetworkStatusAlertWrapper(
                ref: ref,
                child: child!,
              ),
            ),
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

/// 라우트 체크 헬퍼 클래스
class _RouteChecker {
  static bool isPrintProcessScreen(String location) => location.contains('/print-process');
  static bool isHomeScreen(String location) => location.contains('/home');
  static bool isKioskRoute(String location) => location.contains('/kiosk');
  static bool shouldListenToTouch(String location) =>
      isKioskRoute(location) && !isHomeScreen(location) && !isPrintProcessScreen(location);
  static bool shouldStartTimer(String location) =>
      isKioskRoute(location) && !isHomeScreen(location) && !isPrintProcessScreen(location);
}

/// 네트워크 상태 알럿을 표시하는 위젯 (출력 화면 제외)
class _NetworkStatusAlertWrapper extends ConsumerStatefulWidget {
  const _NetworkStatusAlertWrapper({
    required this.child,
    required this.ref,
  });

  final Widget child;
  final WidgetRef ref;

  @override
  ConsumerState<_NetworkStatusAlertWrapper> createState() => _NetworkStatusAlertWrapperState();
}

class _NetworkStatusAlertWrapperState extends ConsumerState<_NetworkStatusAlertWrapper> {
  bool _isAlertShowing = false;
  bool _hasKioskInfo = false;
  NetworkState? _previousState;

  static const _networkAlertTitle = '네트워크 연결이 불안정합니다.';
  static const _networkAlertConfirmText = '확인';
  static const _contextRetryDelay = Duration(milliseconds: 100);

  @override
  Widget build(BuildContext context) {
    _hasKioskInfo = (ref.watch(kioskInfoServiceProvider)?.kioskEventId ?? 0) != 0;
    final networkState = ref.watch(networkStatusNotifierProvider);

    ref.listen<NetworkState>(networkStatusNotifierProvider, (previous, next) {
      _handleNetworkStatusChange(previous, next);
    });

    if (_previousState == null || _previousState!.status != networkState.status) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Future.microtask(() {
            if (mounted) {
              _checkAndShowAlert(networkState);
            }
          });
        }
      });
    }
    _previousState = networkState;

    return widget.child;
  }

  void _checkAndShowAlert(NetworkState networkState) {
    // 오프라인 모드로 운영 - 네트워크 상태 알럿 비활성화
  }

  void _showNetworkAlert() {
    setState(() {
      _isAlertShowing = true;
    });

    // 타임아웃 타이머 종료
    widget.ref.read(homeTimeoutNotifierProvider.notifier).cancelTimer();

    // 타임아웃 알럿이 열려있다면 닫기
    _closeTimeoutDialogIfOpen();

    Future.microtask(() {
      if (!mounted || !_isAlertShowing) return;

      final rootContext = rootNavigatorKey.currentContext;
      if (rootContext != null) {
        _displayNetworkDialog(rootContext);
      } else {
        _retryShowNetworkAlert();
      }
    });
  }

  void _closeTimeoutDialogIfOpen() {
    try {
      final rootContext = rootNavigatorKey.currentContext;
      if (rootContext != null) {
        final navigator = Navigator.of(rootContext, rootNavigator: true);
        // 타임아웃 알럿이 열려있는지 확인하고 닫기
        // Navigator에 열려있는 다이얼로그가 있으면 닫기 (타임아웃 알럿일 가능성이 높음)
        if (navigator.canPop()) {
          navigator.pop();
        }
      }
    } catch (e) {
      // 타임아웃 알럿이 없거나 이미 닫혔을 수 있음
      logger.i('⚠️ NetworkStatusAlert: Failed to close timeout dialog: $e');
    }
  }

  void _displayNetworkDialog(BuildContext context) {
    try {
      DialogHelper.showSetupDialog(
        context,
        title: _networkAlertTitle,
        confirmButtonText: _networkAlertConfirmText,
      ).then((_) {
        logger.i('_hasKioskInfo: $_hasKioskInfo');
        // 이벤트를 불러오지 않은 상태면 앱 종료.
        if (!_hasKioskInfo) {
          exit(0);
        }
        // 확인 버튼을 눌렀을 때 네트워크 상태를 다시 체크
        _resetAlertFlag();
        _recheckNetworkStatusAfterDialogClose();
      }).catchError((error) {
        logger.i('⚠️ NetworkStatusAlert: Dialog error: $error');
        _resetAlertFlag();
        _recheckNetworkStatusAfterDialogClose();
      });
    } catch (e, stack) {
      logger.i('⚠️ NetworkStatusAlert: Failed to show dialog: $e\n$stack');
      _resetAlertFlag();
    }
  }

  void _recheckNetworkStatusAfterDialogClose() {
    // 다이얼로그가 닫힌 후 네트워크 상태를 다시 확인
    Future.microtask(() {
      if (!mounted) return;

      // 네트워크 상태 새로고침
      widget.ref.read(networkStatusNotifierProvider.notifier).refresh();

      // 현재 네트워크 상태 확인
      final currentNetworkState = widget.ref.read(networkStatusNotifierProvider);

      // 여전히 연결이 안 되어 있으면 알럿을 다시 띄우기
      if (currentNetworkState.status == NetworkStatus.unstable ||
          currentNetworkState.status == NetworkStatus.disconnected) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _checkAndShowAlert(currentNetworkState);
          }
        });
      }
    });
  }

  void _retryShowNetworkAlert() {
    Future.delayed(_contextRetryDelay, () {
      if (!mounted || !_isAlertShowing) {
        _resetAlertFlag();
        return;
      }

      final rootContext = rootNavigatorKey.currentContext;
      if (rootContext != null) {
        _displayNetworkDialog(rootContext);
      } else {
        logger.i('⚠️ NetworkStatusAlert: rootNavigatorKey.currentContext still null after retry');
        _resetAlertFlag();
      }
    });
  }

  void _closeNetworkAlert() {
    logger.i('✅ NetworkStatusAlert: Closing alert - network connected');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      try {
        final navigator = rootNavigatorKey.currentState;
        if (navigator != null && navigator.canPop()) {
          navigator.pop();
        } else {
          final nav = Navigator.of(context, rootNavigator: true);
          if (nav.canPop()) {
            nav.pop();
          }
        }
      } catch (e) {
        logger.i('⚠️ NetworkStatusAlert: Failed to close dialog: $e');
      } finally {
        logger.i('⏱️ TimeoutToHome: Resetting timeout timer');
        _resetAlertFlag();
        // 네트워크 알럿이 닫힐 때 타임아웃 타이머 초기화
        _resetTimeoutTimer();
      }
    });
  }

  void _resetTimeoutTimer() {
    widget.ref.read(homeTimeoutNotifierProvider.notifier).resumeTimer();
  }

  void _resetAlertFlag() {
    if (mounted) {
      setState(() {
        _isAlertShowing = false;
      });
    }
  }

  void _handleNetworkStatusChange(NetworkState? previous, NetworkState next) {
    logger.i('🔄 NetworkStatusAlert: Status changed from ${previous?.status} to ${next.status}');
    _checkAndShowAlert(next);
  }
}

/// 타임아웃 후 자동 홈 복귀 위젯 (print-process 화면 제외)
class _TimeoutToHomeWrapper extends ConsumerStatefulWidget {
  const _TimeoutToHomeWrapper({
    required this.child,
    required this.ref,
  });

  final Widget child;
  final WidgetRef ref;

  @override
  ConsumerState<_TimeoutToHomeWrapper> createState() => _TimeoutToHomeWrapperState();
}

class _TimeoutToHomeWrapperState extends ConsumerState<_TimeoutToHomeWrapper> {
  bool _isDialogShowing = false;
  String? _previousRoute;
  String _currentLocation = '';
  late final GoRouter _router;

  static const Duration _contextRetryDelay = Duration(milliseconds: 100);

  @override
  void initState() {
    super.initState();

    _router = ref.read(routerProvider);
    _currentLocation = _router.routerDelegate.currentConfiguration.uri.toString();
    _previousRoute = _currentLocation;

    // 라우트 변경을 직접 구독 (build 리빌드에 의존하지 않음)
    _router.routerDelegate.addListener(_onRouteChanged);
  }

  void _onRouteChanged() {
    if (!mounted) return;

    final nextLocation = _router.routerDelegate.currentConfiguration.uri.toString();
    if (_currentLocation == nextLocation) return;

    // setState를 build 완료 후에 실행하도록 지연
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      setState(() {
        _currentLocation = nextLocation;
      });

      logger.i('⏱️ TimeoutToHome: route changed: $_previousRoute -> $_currentLocation');

      // mounted 체크 후 ref 사용
      if (mounted) {
        _handleRouteChange(_currentLocation);
        _previousRoute = _currentLocation;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_RouteChecker.shouldListenToTouch(_currentLocation)) {
      return Listener(
        onPointerDown: (_) {
          if (mounted) {
            _resetTimer();
          }
        },
        onPointerMove: (_) {
          if (mounted) {
            _resetTimer();
          }
        },
        child: widget.child,
      );
    }
    return widget.child;
  }

  void _resetTimer() {
    if (!mounted || _isDialogShowing) return;
    if (!_RouteChecker.shouldStartTimer(_currentLocation)) return;

    logger.i('⏱️ TimeoutToHome: Touch detected, resetting timer for route: $_currentLocation');
    final timeoutNotifier = ref.read(homeTimeoutNotifierProvider.notifier);
    timeoutNotifier.resetTimer(
      onTimeout: () {
        if (mounted && !_isDialogShowing) {
          _showTimeoutDialog();
        }
      },
    );
  }

  void _handleRouteChange(String currentLocation) {
    if (!mounted) return;

    final timeoutNotifier = ref.read(homeTimeoutNotifierProvider.notifier);
    timeoutNotifier.cancelTimerWithCallback();

    if (_RouteChecker.isHomeScreen(currentLocation)) {
      _resetDialogFlag();
      logger.i('⏱️ TimeoutToHome: Reset flags for home screen');
      return;
    }

    if (_RouteChecker.shouldStartTimer(currentLocation)) {
      _resetDialogFlag();
      if (mounted) {
        timeoutNotifier.startTimer(
          onTimeout: () {
            logger.i('⏱️ TimeoutToHome: Timer expired for route: $currentLocation');
            if (mounted && !_isDialogShowing) {
              _showTimeoutDialog();
            }
          },
        );
      }
    } else {
      logger.i(
          '⏱️ TimeoutToHome: Timer not started for route: $currentLocation (shouldStart: ${_RouteChecker.shouldStartTimer(currentLocation)})');
    }
  }

  void _resetDialogFlag() {
    if (mounted) {
      setState(() {
        _isDialogShowing = false;
      });
    }
  }

  void _showTimeoutDialog() {
    if (!mounted || _isDialogShowing) return;

    if (_RouteChecker.isHomeScreen(_currentLocation) || _RouteChecker.isPrintProcessScreen(_currentLocation)) {
      logger.i('⏱️ TimeoutToHome: Skipping dialog - already on home or print-process screen');
      if (mounted) {
        ref.read(homeTimeoutNotifierProvider.notifier).cancelTimerWithCallback();
      }
      return;
    }

    // 다른 다이얼로그가 이미 열려있는지 확인
    final rootContext = rootNavigatorKey.currentContext;
    if (rootContext != null) {
      final navigator = Navigator.of(rootContext, rootNavigator: true);
      if (navigator.canPop()) {
        logger.i('⏱️ TimeoutToHome: Skipping dialog - another dialog is already showing');
        return;
      }
    }

    setState(() {
      _isDialogShowing = true;
    });

    if (rootContext != null) {
      _displayTimeoutDialog(rootContext);
    } else {
      _retryShowTimeoutDialog();
    }
  }

  void _displayTimeoutDialog(BuildContext context) {
    logger.i('⏱️ TimeoutToHome: Showing timeout dialog');

    DialogHelper.showTimeoutDialog(
      context,
      context.dialogKioskStyle,
      title: LocaleKeys.alert_btn_go_to_home.tr(),
      messageKey: LocaleKeys.alert_txt_timeout_to_home,
      cancelButtonText: LocaleKeys.alert_btn_cancel.tr(),
      confirmButtonText: LocaleKeys.alert_btn_ok.tr(),
      countdownSeconds: 5,
      onAutoClose: () {
        if (mounted) {
          _navigateToHome(context);
        }
      },
    ).then((result) {
      if (!mounted) return;

      _resetDialogFlag();
      ref.read(homeTimeoutNotifierProvider.notifier).cancelTimerWithCallback();

      // 확인 버튼을 누르거나 자동으로 닫힌 경우 (result == true)
      if (result == true) {
        _navigateToHome(context);
      }
      // 취소 버튼을 누른 경우 (result == false)는 알럿만 사라짐
      _resetTimer();
    }).catchError((error) {
      logger.i('⚠️ TimeoutToHome: Dialog error: $error');
      _resetDialogFlag();
    });
  }

  void _retryShowTimeoutDialog() {
    Future.delayed(_contextRetryDelay, () {
      if (!mounted) {
        _resetDialogFlag();
        return;
      }

      final retryContext = rootNavigatorKey.currentContext;
      if (retryContext != null) {
        _showTimeoutDialog();
      } else {
        _resetDialogFlag();
      }
    });
  }

  void _navigateToHome(BuildContext context) {
    try {
      const HomeRouteData().go(context);
      logger.i('⏱️ TimeoutToHome: Navigated to home');
    } catch (e) {
      logger.i('⚠️ TimeoutToHome: Failed to navigate to home: $e');
    }
  }

  @override
  void dispose() {
    _router.routerDelegate.removeListener(_onRouteChanged);
    // ref는 dispose에서 사용할 수 없으므로, provider의 onDispose에서 처리됨
    super.dispose();
  }
}
