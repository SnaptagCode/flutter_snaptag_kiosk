part of 'router.dart';

final GlobalKey<NavigatorState> kioskNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'kiosk');

@TypedShellRoute<KioskShellRouteData>(
  routes: <TypedRoute<RouteData>>[
    TypedGoRoute<QRRouteData>(path: '/kiosk-qr'),
    TypedGoRoute<ApprovalRouteData>(path: '/kiosk-keypad'),
    TypedGoRoute<ConfirmationRouteData>(path: '/kiosk-payment'),
    TypedGoRoute<PrintRouteData>(path: '/kiosk-print'),
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

class QRRouteData extends GoRouteData {
  const QRRouteData();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return NoTransitionPage(
      child: const Scaffold(
        body: Center(
          child: Text('QR Code'),
        ),
      ),
    );
  }
}

class ApprovalRouteData extends GoRouteData {
  const ApprovalRouteData();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return NoTransitionPage(
      child: const Scaffold(
        body: Center(
          child: Text('Approval'),
        ),
      ),
    );
  }
}

class ConfirmationRouteData extends GoRouteData {
  const ConfirmationRouteData();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return NoTransitionPage(
      child: const Scaffold(
        body: Center(
          child: Text('Confirmation'),
        ),
      ),
    );
  }
}

class PrintRouteData extends GoRouteData {
  const PrintRouteData();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return NoTransitionPage(
      child: const Scaffold(
        body: Center(
          child: Text('Print'),
        ),
      ),
    );
  }
}
