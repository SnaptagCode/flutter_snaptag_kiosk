part of 'router.dart';

final GlobalKey<NavigatorState> adminNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'debug');

@TypedShellRoute<DebugShellRouteData>(
  routes: <TypedRoute<RouteData>>[
    TypedGoRoute<PrintTestRouteData>(path: '/print-test'),
    TypedGoRoute<PaymentHistoryRouteData>(path: '/payment-history'),
    TypedGoRoute<ApiDebugRouteData>(path: '/api-debug'),
    TypedGoRoute<MaterialRouteData>(path: '/material-components'),
    TypedGoRoute<KioskComponentsRouteData>(path: '/kiosk-components'),
    TypedGoRoute<KioskInfoRouteData>(path: '/kiosk-info'),
    TypedGoRoute<LabcurityImageTestRouteData>(path: '/security-image-test'), // 새로운 경로 추가
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

class PrintTestRouteData extends GoRouteData {
  const PrintTestRouteData();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return NoTransitionPage(
      child: const PrintTestScreen(),
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

class LabcurityImageTestRouteData extends GoRouteData {
  const LabcurityImageTestRouteData();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return NoTransitionPage(
      child: LabcurityImageScreen(),
    );
  }
}
