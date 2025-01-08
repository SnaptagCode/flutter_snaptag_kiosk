import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_snaptag_kiosk/data/data.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';

void main() async {
  if (kDebugMode) {
    F.appFlavor = Flavor.dev;
  } else {
    F.appFlavor = Flavor.prod;
  }
  final yamlStorage = await YamlStorageService.initialize();
  final imageStorage = await ImageStorageService.initialize();
  WidgetsFlutterBinding.ensureInitialized();
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
        observers: [RiverpodLogger()],
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
}
