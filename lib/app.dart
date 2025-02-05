import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            ...themeData.extensions.values,
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
              onRetry: () => ref.refresh(asyncKioskInfoProvider),
            );
          }),
        ),
      ),
    );
  }
}
