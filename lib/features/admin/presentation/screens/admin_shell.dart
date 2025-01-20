import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_snaptag_kiosk/flavors.dart';
import 'package:flutter_snaptag_kiosk/routers/routers.dart';
import 'package:go_router/go_router.dart';

class AdminShell extends ConsumerWidget {
  const AdminShell({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (index) => _onDestinationSelected(context, index),
        selectedIndex: _calculateSelectedIndex(context),
        destinations: _buildDestinations(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          PhotoCardUploadRouteData().go(context);
        },
        child: const Icon(Icons.drive_file_move_rounded),
      ),
    );
  }

  void _onDestinationSelected(BuildContext context, int index) {
    final routes = _getRoutes();
    if (index < routes.length) {
      context.go(routes[index].path);
    }
  }

  List<NavigationDestination> _buildDestinations() {
    return _getRoutes().map((route) => route.destination).toList();
  }

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    final paths = _getRoutes().map((route) => route.path).toList();
    return paths.indexWhere(location.startsWith);
  }

  List<RouteModel> _getRoutes() {
    final routes = [
      RouteModel(
        path: '/kiosk-info',
        route: const KioskInfoRouteData(),
        destination: const NavigationDestination(
          icon: Icon(Icons.info),
          label: 'Kiosk Info',
        ),
      ),
      RouteModel(
        path: '/payment-history',
        route: const PaymentHistoryRouteData(),
        destination: const NavigationDestination(
          icon: Icon(Icons.history),
          label: 'Payment History',
        ),
      ),
      RouteModel(
        path: '/print-test',
        route: const PrintTestRouteData(),
        destination: const NavigationDestination(
          icon: Icon(Icons.print),
          label: 'Print',
        ),
      ),
    ];

    if (F.appFlavor == Flavor.dev) {
      routes.addAll([
        RouteModel(
          path: '/unit-test',
          route: const UnitTestRouteData(),
          destination: const NavigationDestination(
            icon: Icon(Icons.api),
            label: 'Debug',
          ),
        ),
        RouteModel(
          path: '/material-components',
          route: const MaterialRouteData(),
          destination: const NavigationDestination(
            icon: Icon(Icons.widgets),
            label: 'Material',
          ),
        ),
        RouteModel(
          path: '/kiosk-components',
          route: const KioskComponentsRouteData(),
          destination: const NavigationDestination(
            icon: Icon(Icons.devices),
            label: 'Kiosk Components',
          ),
        ),
      ]);
    }

    return routes;
  }
}

class RouteModel {
  final String path;
  final GoRouteData route;
  final NavigationDestination destination;

  RouteModel({
    required this.path,
    required this.route,
    required this.destination,
  });
}
