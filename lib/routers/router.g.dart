// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'router.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [
      $splashRoute,
      $adminShellRouteData,
      $debugShellRouteData,
      $kioskShellRouteData,
    ];

RouteBase get $splashRoute => GoRouteData.$route(
      path: '/splash',
      factory: $SplashRouteExtension._fromState,
    );

extension $SplashRouteExtension on SplashRoute {
  static SplashRoute _fromState(GoRouterState state) => const SplashRoute();

  String get location => GoRouteData.$location(
        '/splash',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) => context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $adminShellRouteData => ShellRouteData.$route(
      navigatorKey: AdminShellRouteData.$navigatorKey,
      factory: $AdminShellRouteDataExtension._fromState,
      routes: [
        GoRouteData.$route(
          path: '/printer-settings',
          factory: $PrinterSettingRouteDataExtension._fromState,
        ),
        GoRouteData.$route(
          path: '/payment-history',
          factory: $PaymentHistoryRouteDataExtension._fromState,
        ),
        GoRouteData.$route(
          path: '/admin-tab',
          factory: $AdminTabRouteDataExtension._fromState,
        ),
      ],
    );

extension $AdminShellRouteDataExtension on AdminShellRouteData {
  static AdminShellRouteData _fromState(GoRouterState state) => const AdminShellRouteData();
}

extension $PrinterSettingRouteDataExtension on PrinterSettingRouteData {
  static PrinterSettingRouteData _fromState(GoRouterState state) => const PrinterSettingRouteData();

  String get location => GoRouteData.$location(
        '/printer-settings',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) => context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $PaymentHistoryRouteDataExtension on PaymentHistoryRouteData {
  static PaymentHistoryRouteData _fromState(GoRouterState state) => const PaymentHistoryRouteData();

  String get location => GoRouteData.$location(
        '/payment-history',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) => context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $AdminTabRouteDataExtension on AdminTabRouteData {
  static AdminTabRouteData _fromState(GoRouterState state) => const AdminTabRouteData();

  String get location => GoRouteData.$location(
        '/admin-tab',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) => context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $debugShellRouteData => ShellRouteData.$route(
      navigatorKey: DebugShellRouteData.$navigatorKey,
      factory: $DebugShellRouteDataExtension._fromState,
      routes: [
        GoRouteData.$route(
          path: '/api-debug',
          factory: $ApiDebugRouteDataExtension._fromState,
        ),
        GoRouteData.$route(
          path: '/material-components',
          factory: $MaterialRouteDataExtension._fromState,
        ),
        GoRouteData.$route(
          path: '/kiosk-components',
          factory: $KioskComponentsRouteDataExtension._fromState,
        ),
        GoRouteData.$route(
          path: '/kiosk-info',
          factory: $KioskInfoRouteDataExtension._fromState,
        ),
        GoRouteData.$route(
          path: '/kiosk-typography',
          factory: $KioskTypographyRouteDataExtension._fromState,
        ),
        GoRouteData.$route(
          path: '/kiosk-colors',
          factory: $KioskColorsRouteDataExtension._fromState,
        ),
      ],
    );

extension $DebugShellRouteDataExtension on DebugShellRouteData {
  static DebugShellRouteData _fromState(GoRouterState state) => const DebugShellRouteData();
}

extension $ApiDebugRouteDataExtension on ApiDebugRouteData {
  static ApiDebugRouteData _fromState(GoRouterState state) => const ApiDebugRouteData();

  String get location => GoRouteData.$location(
        '/api-debug',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) => context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $MaterialRouteDataExtension on MaterialRouteData {
  static MaterialRouteData _fromState(GoRouterState state) => const MaterialRouteData();

  String get location => GoRouteData.$location(
        '/material-components',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) => context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $KioskComponentsRouteDataExtension on KioskComponentsRouteData {
  static KioskComponentsRouteData _fromState(GoRouterState state) => const KioskComponentsRouteData();

  String get location => GoRouteData.$location(
        '/kiosk-components',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) => context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $KioskInfoRouteDataExtension on KioskInfoRouteData {
  static KioskInfoRouteData _fromState(GoRouterState state) => const KioskInfoRouteData();

  String get location => GoRouteData.$location(
        '/kiosk-info',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) => context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $KioskTypographyRouteDataExtension on KioskTypographyRouteData {
  static KioskTypographyRouteData _fromState(GoRouterState state) => const KioskTypographyRouteData();

  String get location => GoRouteData.$location(
        '/kiosk-typography',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) => context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $KioskColorsRouteDataExtension on KioskColorsRouteData {
  static KioskColorsRouteData _fromState(GoRouterState state) => const KioskColorsRouteData();

  String get location => GoRouteData.$location(
        '/kiosk-colors',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) => context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $kioskShellRouteData => ShellRouteData.$route(
      navigatorKey: KioskShellRouteData.$navigatorKey,
      factory: $KioskShellRouteDataExtension._fromState,
      routes: [
        ShellRouteData.$route(
          navigatorKey: ContentsShellRouteData.$navigatorKey,
          factory: $KioskContentsShellRouteDataExtension._fromState,
          routes: [
            GoRouteData.$route(
              path: '/kiosk/qr',
              factory: $PhotoCardUploadRouteDataExtension._fromState,
            ),
            GoRouteData.$route(
              path: '/kiosk/code-verification',
              factory: $CodeVerificationRouteDataExtension._fromState,
            ),
            GoRouteData.$route(
              path: '/kiosk/preview',
              factory: $PhotoCardPreviewRouteDataExtension._fromState,
            ),
            GoRouteData.$route(
              path: '/kiosk/print-process',
              factory: $PrintProcessRouteDataExtension._fromState,
            ),
          ],
        ),
      ],
    );

extension $KioskShellRouteDataExtension on KioskShellRouteData {
  static KioskShellRouteData _fromState(GoRouterState state) => const KioskShellRouteData();
}

extension $KioskContentsShellRouteDataExtension on ContentsShellRouteData {
  static ContentsShellRouteData _fromState(GoRouterState state) => const ContentsShellRouteData();
}

extension $PhotoCardUploadRouteDataExtension on PhotoCardUploadRouteData {
  static PhotoCardUploadRouteData _fromState(GoRouterState state) => const PhotoCardUploadRouteData();

  String get location => GoRouteData.$location(
        '/kiosk/qr',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) => context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $CodeVerificationRouteDataExtension on CodeVerificationRouteData {
  static CodeVerificationRouteData _fromState(GoRouterState state) => const CodeVerificationRouteData();

  String get location => GoRouteData.$location(
        '/kiosk/code-verification',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) => context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $PhotoCardPreviewRouteDataExtension on PhotoCardPreviewRouteData {
  static PhotoCardPreviewRouteData _fromState(GoRouterState state) => const PhotoCardPreviewRouteData();

  String get location => GoRouteData.$location(
        '/kiosk/preview',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) => context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $PrintProcessRouteDataExtension on PrintProcessRouteData {
  static PrintProcessRouteData _fromState(GoRouterState state) => const PrintProcessRouteData();

  String get location => GoRouteData.$location(
        '/kiosk/print-process',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) => context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$routerHash() => r'9db931a9d21736df5752251734cb1e846846cb05';

/// See also [router].
@ProviderFor(router)
final routerProvider = AutoDisposeProvider<GoRouter>.internal(
  router,
  name: r'routerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product') ? null : _$routerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RouterRef = AutoDisposeProviderRef<GoRouter>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
