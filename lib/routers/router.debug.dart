part of 'router.dart';

final GlobalKey<NavigatorState> debugNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'debug');

@TypedShellRoute<DebugShellRouteData>(
  routes: <TypedRoute<RouteData>>[
    TypedGoRoute<ApiDebugRouteData>(path: '/api-debug'),
    TypedGoRoute<MaterialRouteData>(path: '/material-components'),
    TypedGoRoute<KioskComponentsRouteData>(path: '/kiosk-components'),
    TypedGoRoute<KioskInfoRouteData>(path: '/kiosk-info'),
    TypedGoRoute<KioskTypographyRouteData>(path: '/kiosk-typography'),
    TypedGoRoute<KioskColorsRouteData>(path: '/kiosk-colors'),
  ],
)
class DebugShellRouteData extends ShellRouteData {
  const DebugShellRouteData();

  static final GlobalKey<NavigatorState> $navigatorKey = debugNavigatorKey;

  @override
  Widget builder(BuildContext context, GoRouterState state, Widget navigator) {
    return DebugShell(child: navigator);
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

class KioskColorsRouteData extends GoRouteData {
  const KioskColorsRouteData();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return NoTransitionPage(
      child: const KioskColorsScreen(),
    );
  }
}

class KioskTypographyRouteData extends GoRouteData {
  const KioskTypographyRouteData();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return NoTransitionPage(
      child: const KioskTypographyScreen(),
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
