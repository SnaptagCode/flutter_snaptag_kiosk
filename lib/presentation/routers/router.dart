import 'package:flutter/material.dart';
import 'package:flutter_snaptag_kiosk/presentation/verification/code_verification_screen.dart';
import 'package:flutter_snaptag_kiosk/presentation/global_shell.dart';
import 'package:flutter_snaptag_kiosk/presentation/setup/kiosk_components_screen.dart';
import 'package:flutter_snaptag_kiosk/presentation/setup/kiosk_info_screen.dart';
import 'package:flutter_snaptag_kiosk/presentation/kiosk_shell/kiosk_shell.dart';
import 'package:flutter_snaptag_kiosk/presentation/setup/maintenance_screen.dart';
import 'package:flutter_snaptag_kiosk/presentation/home/home_screen.dart';
import 'package:flutter_snaptag_kiosk/presentation/setup/payment_history_screen.dart';
import 'package:flutter_snaptag_kiosk/presentation/setup/setup_main_screen.dart';
import 'package:flutter_snaptag_kiosk/presentation/test/unit_test_screen.dart';
import 'package:flutter_snaptag_kiosk/presentation/payment/payment_screen.dart';
import 'package:flutter_snaptag_kiosk/presentation/print/print_process_screen.dart';
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
            TypedGoRoute<HomeRouteData>(path: 'home'),
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

class HomeRouteData extends GoRouteData with _$HomeRouteData {
  const HomeRouteData();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return NoTransitionPage(
      child: HomeScreen(),
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
      child: const PaymentScreen(),
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
