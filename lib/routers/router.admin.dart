part of 'router.dart';

final GlobalKey<NavigatorState> adminNavigatorKey = GlobalKey<NavigatorState>();

@TypedShellRoute<AdminShellRouteData>(
  routes: <TypedRoute<RouteData>>[
    TypedGoRoute<PrinterSettingRouteData>(path: '/printer-settings'),
    TypedGoRoute<PaymentHistoryRouteData>(path: '/payment-history'),
    TypedGoRoute<AdminTabRouteData>(path: '/admin-tab'),
  ],
)
class AdminShellRouteData extends ShellRouteData {
  const AdminShellRouteData();

  static final GlobalKey<NavigatorState> $navigatorKey = adminNavigatorKey;

  @override
  Widget builder(BuildContext context, GoRouterState state, Widget navigator) {
    return AdminShell(child: navigator);
  }
}

class PrinterSettingRouteData extends GoRouteData {
  const PrinterSettingRouteData();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return NoTransitionPage(
      child: const PrinterSettingScreen(),
    );
  }
}

class PaymentHistoryRouteData extends GoRouteData {
  const PaymentHistoryRouteData();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return NoTransitionPage(
      child: PaymentHistoryScreen(),
    );
  }
}

class AdminTabRouteData extends GoRouteData {
  const AdminTabRouteData();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return NoTransitionPage(
      child: AdminTabScreen(),
    );
  }
}
