import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              const KioskInfoRouteData().go(context);
              break;
            case 1:
              const ApiDebugRouteData().go(context);
              break;
            case 2:
              const MaterialRouteData().go(context);
              break;
            case 3:
              const KioskColorsRouteData().go(context);
              break;
            case 4:
              const KioskTypographyRouteData().go(context);
              break;
            case 5:
              const KioskComponentsRouteData().go(context);
              break;
            case 6:
              const ImageStorageRouteData().go(context);
              break;
          }
        },
        selectedIndex: _calculateSelectedIndex(context),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.info),
            label: 'Kiosk Info',
          ),
          NavigationDestination(
            icon: Icon(Icons.api),
            label: 'API Debug',
          ),
          NavigationDestination(
            icon: Icon(Icons.widgets),
            label: 'Material',
          ),
          NavigationDestination(
            icon: Icon(Icons.color_lens),
            label: 'Colors',
          ),
          NavigationDestination(
            icon: Icon(Icons.text_fields),
            label: 'Typography',
          ),
          NavigationDestination(
            icon: Icon(Icons.devices),
            label: 'Kiosk Components',
          ),
          NavigationDestination(
            icon: Icon(Icons.image),
            label: 'Image Storage',
          ),
        ],
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/kiosk-info')) return 0;
    if (location.startsWith('/api-debug')) return 1;
    if (location.startsWith('/material-components')) return 2;
    if (location.startsWith('/kiosk-colors')) return 3;
    if (location.startsWith('/kiosk-typography')) return 4;
    if (location.startsWith('/kiosk-components')) return 5;
    if (location.startsWith('/image-storage')) return 6;
    return 0;
  }
}
