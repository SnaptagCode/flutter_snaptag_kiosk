part of 'router.dart';

final GlobalKey<NavigatorState> kioskNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'kiosk');
final GlobalKey<NavigatorState> contentsNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'kiosk-contents');

@TypedShellRoute<KioskShellRouteData>(
  routes: [
    TypedShellRoute<ContentsShellRouteData>(
      routes: <TypedRoute<RouteData>>[
        TypedGoRoute<PhotoCardUploadRouteData>(path: '/kiosk/qr'),
        TypedGoRoute<CodeVerificationRouteData>(path: '/kiosk/code-verification'),
        TypedGoRoute<PhotoCardPreviewRouteData>(path: '/kiosk/preview'),
        TypedGoRoute<PrintProcessRouteData>(path: '/kiosk/print-process'),
      ],
    )
  ],
)
class KioskShellRouteData extends ShellRouteData {
  const KioskShellRouteData();

  static final GlobalKey<NavigatorState> $navigatorKey = kioskNavigatorKey;

  @override
  Widget builder(BuildContext context, GoRouterState state, Widget navigator) {
    return KioskShell(child: navigator);
  }
}

class ContentsShellRouteData extends ShellRouteData {
  const ContentsShellRouteData();

  static final GlobalKey<NavigatorState> $navigatorKey = contentsNavigatorKey;

  @override
  Widget builder(BuildContext context, GoRouterState state, Widget navigator) {
    return ContentsShell(child: navigator);
  }
}

class PhotoCardUploadRouteData extends GoRouteData {
  const PhotoCardUploadRouteData();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return NoTransitionPage(
      child: PhotoCardUploadScreen(),
    );
  }
}

class CodeVerificationRouteData extends GoRouteData {
  const CodeVerificationRouteData();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return NoTransitionPage(
      child: CodeVerificationScreen(),
    );
  }
}

class PhotoCardPreviewRouteData extends GoRouteData {
  const PhotoCardPreviewRouteData({required this.$extra});
  final BackPhotoCardResponse $extra;
  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return NoTransitionPage(
        child: ProviderScope(
      overrides: [
        backPhotoCardResponseInfoProvider.overrideWithValue($extra),
      ],
      child: PhotoCardPreviewScreen(),
    ));
  }
}

class PrintProcessRouteData extends GoRouteData {
  const PrintProcessRouteData();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return NoTransitionPage(
      child: PrintProcessScreen(),
    );
  }
}
