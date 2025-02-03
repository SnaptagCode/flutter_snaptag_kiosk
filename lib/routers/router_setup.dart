part of 'router.dart';

final GlobalKey<NavigatorState> setupNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'setup');

@TypedGoRoute<SetupMainRouteData>(
  path: '/setup',
  routes: [
    TypedGoRoute<PaymentHistoryRouteData>(path: 'payment-history'),
    TypedGoRoute<UnitTestRouteData>(path: 'unit-test'),
    TypedGoRoute<MaterialRouteData>(path: 'material-components'),
    TypedGoRoute<KioskComponentsRouteData>(path: 'kiosk-components'),
    TypedGoRoute<KioskInfoRouteData>(path: 'kiosk-info'),
  ],
)
class SetupMainRouteData extends GoRouteData {
  const SetupMainRouteData();

  static final GlobalKey<NavigatorState> $navigatorKey = setupNavigatorKey;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return NoTransitionPage(
      child: SetupMainScreen(),
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
