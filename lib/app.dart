import 'dart:io';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_snaptag_kiosk/core/providers/network_status_provider.dart';
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
      // _hasInitializedKioskInfo = true;

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
            child: _NetworkStatusAlertWrapper(
              child: child!,
              ref: ref,
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
  NetworkState? _previousState;

  @override
  Widget build(BuildContext context) {
    final networkState = ref.watch(networkStatusNotifierProvider);

    // 네트워크 상태 변경 감지 (build 메서드 내에서만 ref.listen 사용 가능)
    ref.listen<NetworkState>(networkStatusNotifierProvider, (previous, next) {
      _handleNetworkStatusChange(previous, next);
    });

    // 초기 상태 체크 또는 상태 변경 시 체크
    if (_previousState == null || _previousState!.status != networkState.status) {
      // 다음 프레임에서 체크하여 context가 완전히 준비된 후 다이얼로그 표시
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          // 추가로 마이크로태스크를 사용하여 다이얼로그 표시 보장
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
    if (!mounted) return;

    // routerProvider를 통해 router 가져오기
    final router = widget.ref.read(routerProvider);
    final currentLocation = router.routerDelegate.currentConfiguration.uri.toString();
    final isPrintProcessScreen = currentLocation.contains('/print-process');

    logger.i(
        '📡 NetworkStatusAlert: _isAlertShowing: $_isAlertShowing status=${networkState.status}, hasInternet=${networkState.hasInternet}, isPrintProcessScreen=$isPrintProcessScreen, isAlertShowing=$_isAlertShowing');

    // 출력 화면이 아니고 네트워크가 불안정하거나 연결 끊김 상태일 때
    if (!isPrintProcessScreen &&
        (networkState.status == NetworkStatus.unstable || networkState.status == NetworkStatus.disconnected)) {
      // 알럿이 표시되지 않았을 때만 표시
      if (!_isAlertShowing) {
        logger.i('🚨 NetworkStatusAlert: Showing alert for status=${networkState.status}');
        setState(() {
          _isAlertShowing = true;
        });
        // 다음 마이크로태스크에서 다이얼로그 표시 (context가 완전히 준비된 후)
        Future.microtask(() {
          if (mounted && _isAlertShowing) {
            logger.i('🚨 NetworkStatusAlert: Actually showing dialog now');
            // rootNavigatorKey의 context를 사용하여 다이얼로그 표시
            final rootContext = rootNavigatorKey.currentContext;
            if (rootContext != null) {
              logger.i('🚨 NetworkStatusAlert: Using rootNavigatorKey context');
              try {
                final result = DialogHelper.showSetupOneButtonDialog(
                  rootContext,
                  title: '네트워크 연결이 불안정합니다.',
                  confirmButtonText: '확인',
                );
                logger.i('🚨 NetworkStatusAlert: Dialog call returned, waiting for result...');
                result.then((_) {
                  logger.i('🚨 NetworkStatusAlert: Dialog closed');
                  if (mounted) {
                    setState(() {
                      _isAlertShowing = false;
                    });
                  }
                }).catchError((error) {
                  logger.i('⚠️ NetworkStatusAlert: Dialog error: $error');
                  if (mounted) {
                    setState(() {
                      _isAlertShowing = false;
                    });
                  }
                });
              } catch (e, stack) {
                logger.i('⚠️ NetworkStatusAlert: Failed to show dialog: $e');
                logger.i('⚠️ NetworkStatusAlert: Stack: $stack');
                if (mounted) {
                  setState(() {
                    _isAlertShowing = false;
                  });
                }
              }
            } else {
              logger.i('⚠️ NetworkStatusAlert: rootNavigatorKey.currentContext is null, waiting for context...');
              // rootNavigatorKey의 context가 준비될 때까지 대기
              Future.delayed(const Duration(milliseconds: 100), () {
                if (mounted && _isAlertShowing) {
                  final rootContext = rootNavigatorKey.currentContext;
                  if (rootContext != null) {
                    try {
                      DialogHelper.showSetupOneButtonDialog(
                        rootContext,
                        title: '네트워크 연결이 불안정합니다.',
                        confirmButtonText: '확인',
                      ).then((_) {
                        if (mounted) {
                          setState(() {
                            _isAlertShowing = false;
                          });
                        }
                      }).catchError((error) {
                        logger.i('⚠️ NetworkStatusAlert: Dialog error (retry): $error');
                        if (mounted) {
                          setState(() {
                            _isAlertShowing = false;
                          });
                        }
                      });
                    } catch (e) {
                      logger.i('⚠️ NetworkStatusAlert: Failed to show dialog (retry): $e');
                      if (mounted) {
                        setState(() {
                          _isAlertShowing = false;
                        });
                      }
                    }
                  } else {
                    logger.i('⚠️ NetworkStatusAlert: rootNavigatorKey.currentContext still null after retry');
                    if (mounted) {
                      setState(() {
                        _isAlertShowing = false;
                      });
                    }
                  }
                }
              });
            }
          } else {
            logger.i('⚠️ NetworkStatusAlert: Not showing dialog - mounted: $mounted, isAlertShowing: $_isAlertShowing');
          }
        });
      }
    } else if (networkState.status == NetworkStatus.connected) {
      // 네트워크가 다시 연결되면 알럿 닫기
      if (_isAlertShowing) {
        logger.i('✅ NetworkStatusAlert: Closing alert - network connected');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            try {
              // rootNavigatorKey를 사용하여 다이얼로그 닫기
              final navigator = rootNavigatorKey.currentState;
              if (navigator != null && navigator.canPop()) {
                navigator.pop();
                setState(() {
                  _isAlertShowing = false;
                });
              } else {
                // rootNavigatorKey가 없으면 rootNavigator 시도
                final nav = Navigator.of(context, rootNavigator: true);
                if (nav.canPop()) {
                  nav.pop();
                  setState(() {
                    _isAlertShowing = false;
                  });
                } else {
                  // Navigator를 찾을 수 없으면 플래그만 리셋
                  setState(() {
                    _isAlertShowing = false;
                  });
                }
              }
            } catch (e) {
              logger.i('⚠️ NetworkStatusAlert: Failed to close dialog: $e');
              // Navigator를 찾을 수 없으면 플래그만 리셋
              setState(() {
                _isAlertShowing = false;
              });
            }
          }
        });
      }
    }
  }

  void _handleNetworkStatusChange(NetworkState? previous, NetworkState next) {
    print('🔄 NetworkStatusAlert: Status changed from ${previous?.status} to ${next.status}');
    _checkAndShowAlert(next);
  }
}
