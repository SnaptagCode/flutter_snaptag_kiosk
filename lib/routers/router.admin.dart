part of 'router.dart';

final GlobalKey<NavigatorState> adminNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'debug');

@TypedShellRoute<DebugShellRouteData>(
  routes: <TypedRoute<RouteData>>[
    TypedGoRoute<PaymentHistoryRouteData>(path: '/payment-history'),
    TypedGoRoute<UnitTestRouteData>(path: '/unit-test'),
    TypedGoRoute<MaterialRouteData>(path: '/material-components'),
    TypedGoRoute<KioskComponentsRouteData>(path: '/kiosk-components'),
    TypedGoRoute<KioskInfoRouteData>(path: '/kiosk-info'),
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

class PaymentHistoryRouteData extends GoRouteData {
  const PaymentHistoryRouteData();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return NoTransitionPage(
      child: PaymentHistoryScreen(),
    );
  }
}

class UnitTestRouteData extends GoRouteData {
  const UnitTestRouteData();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return NoTransitionPage(
      child: const UnitTestScreen(),
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
