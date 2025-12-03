import 'package:flutter/material.dart';
import 'package:flutter_snaptag_kiosk/features/move_me/screens/global_shell.dart';
import 'package:flutter_snaptag_kiosk/features/move_me/screens/maintenance_screen.dart';
import 'package:flutter_snaptag_kiosk/features/move_me/screens/choice_screen.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:go_router/go_router.dart';

part 'router.g.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

final GlobalKey<NavigatorState> globalNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'global');

@TypedShellRoute<GlobalShellRouteData>(
  routes: [
    TypedGoRoute<SetupMainRouteData>(
      path: '/setup',
      routes: [
        TypedGoRoute<KioskInfoRouteData>(path: 'kiosk-info'),
        TypedGoRoute<PaymentHistoryRouteData>(path: 'payment-history'),
        TypedGoRoute<UnitTestRouteData>(path: 'unit-test'),
        TypedGoRoute<KioskComponentsRouteData>(path: 'kiosk-components'),
        TypedGoRoute<MaintenanceRouteData>(path: 'maintenance'),
      ],
    ),
    TypedGoRoute<KioskRouteData>(
      path: '/kiosk',
      routes: [
        TypedShellRoute<ImageShellRouteData>(
          routes: <TypedRoute<RouteData>>[
            TypedGoRoute<ChoiceRouteData>(path: 'choice'),
            TypedGoRoute<PhotoCardUploadRouteData>(path: 'qr'),
            TypedGoRoute<CodeVerificationRouteData>(path: 'code-verification'),
            TypedGoRoute<PhotoCardPreviewRouteData>(path: 'preview'),
            TypedGoRoute<PrintProcessRouteData>(path: 'print-process'),
          ],
        ),
      ],
    )
  ],
)
class GlobalShellRouteData extends ShellRouteData {
  const GlobalShellRouteData();

  @override
  Widget builder(BuildContext context, GoRouterState state, Widget navigator) {
    return GlobalShell(child: navigator);
  }
}

class ImageShellRouteData extends ShellRouteData {
  const ImageShellRouteData();

  @override
  Widget builder(BuildContext context, GoRouterState state, Widget navigator) {
    return KioskShell(child: navigator);
  }
}

class SetupMainRouteData extends GoRouteData with _$SetupMainRouteData {
  const SetupMainRouteData();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return NoTransitionPage(
      child: SetupMainScreen(),
    );
  }
}

class PaymentHistoryRouteData extends GoRouteData with _$PaymentHistoryRouteData {
  const PaymentHistoryRouteData();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return NoTransitionPage(
      child: PaymentHistoryScreen(),
    );
  }
}

class UnitTestRouteData extends GoRouteData with _$UnitTestRouteData {
  const UnitTestRouteData();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return NoTransitionPage(
      child: const UnitTestScreen(),
    );
  }
}

class KioskComponentsRouteData extends GoRouteData with _$KioskComponentsRouteData {
  const KioskComponentsRouteData();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return NoTransitionPage(
      child: const KioskComponentsScreen(),
    );
  }
}

class KioskInfoRouteData extends GoRouteData with _$KioskInfoRouteData {
  const KioskInfoRouteData();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return NoTransitionPage(
      child: const KioskInfoScreen(),
    );
  }
}

class KioskRouteData extends GoRouteData with _$KioskRouteData {
  const KioskRouteData();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return NoTransitionPage(
      child: SizedBox(),
    );
  }
}

class ChoiceRouteData extends GoRouteData with _$ChoiceRouteData {
  const ChoiceRouteData();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return NoTransitionPage(
      child: ChoiceScreen(),
    );
  }
}

class PhotoCardUploadRouteData extends GoRouteData with _$PhotoCardUploadRouteData {
  const PhotoCardUploadRouteData();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return NoTransitionPage(
      child: PhotoCardUploadScreen(),
    );
  }
}

class CodeVerificationRouteData extends GoRouteData with _$CodeVerificationRouteData {
  const CodeVerificationRouteData();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return NoTransitionPage(
      child: CodeVerificationScreen(),
    );
  }
}

class PhotoCardPreviewRouteData extends GoRouteData with _$PhotoCardPreviewRouteData {
  const PhotoCardPreviewRouteData();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return NoTransitionPage(
      child: const PhotoCardPreviewScreen(),
    );
  }
}

class PrintProcessRouteData extends GoRouteData with _$PrintProcessRouteData {
  const PrintProcessRouteData();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return NoTransitionPage(
      child: const PrintProcessScreen(),
    );
  }
}

class MaintenanceRouteData extends GoRouteData with _$MaintenanceRouteData {
  const MaintenanceRouteData();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return NoTransitionPage(
      child: const MaintenanceScreen(),
    );
  }
}
