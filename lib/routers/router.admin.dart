part of 'router.dart';

final GlobalKey<NavigatorState> adminNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'debug');

@TypedShellRoute<DebugShellRouteData>(
  routes: <TypedRoute<RouteData>>[
    TypedGoRoute<PrinterSettingRouteData>(path: '/printer-settings'),
    TypedGoRoute<PaymentHistoryRouteData>(path: '/payment-history'),
    TypedGoRoute<ApiDebugRouteData>(path: '/api-debug'),
    TypedGoRoute<MaterialRouteData>(path: '/material-components'),
    TypedGoRoute<KioskComponentsRouteData>(path: '/kiosk-components'),
    TypedGoRoute<KioskInfoRouteData>(path: '/kiosk-info'),
    TypedGoRoute<PaymentRequestTestRouteData>(path: '/payment-request-test'),
  ],
)
class DebugShellRouteData extends ShellRouteData {
  const DebugShellRouteData();

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

class ApiDebugRouteData extends GoRouteData {
  const ApiDebugRouteData();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return NoTransitionPage(
      child: const ApiDebugScreen(),
    );
  }
}

class MaterialRouteData extends GoRouteData {
  const MaterialRouteData();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return NoTransitionPage(
      child: const MaterialScreen(),
    );
  }
}

class KioskComponentsRouteData extends GoRouteData {
  const KioskComponentsRouteData();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return NoTransitionPage(
      child: const KioskComponentsScreen(),
    );
  }
}

class KioskInfoRouteData extends GoRouteData {
  const KioskInfoRouteData();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return NoTransitionPage(
      child: const KioskInfoScreen(),
    );
  }
}

class PaymentRequestTestRouteData extends GoRouteData {
  const PaymentRequestTestRouteData();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return NoTransitionPage(
      child: const PaymentRequestTestScreen(),
    );
  }
}
