import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_snaptag_kiosk/features/features.dart';

import 'routers/router.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    final kioskInfo = ref.watch(asyncKioskInfoProvider);
    return kioskInfo.when(
      data: (info) {
        final theme = ref.watch(themeNotifierProvider);
        return theme.when(
          data: (themeData) => MaterialApp.router(
            debugShowCheckedModeBanner: false,
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            themeMode: ThemeMode.light,
            theme: themeData.copyWith(
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
          ),
          loading: () => const _LoadingApp(),
          error: (error, stack) => _ErrorApp(error: error),
        );
      },
      loading: () => const _LoadingApp(),
      error: (error, stack) => _ErrorApp(error: error),
    );
  }
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

class _ErrorApp extends StatelessWidget {
  const _ErrorApp({required this.error});
  final Object error;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }
}
