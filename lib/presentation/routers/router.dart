import 'package:flutter/material.dart';
import 'package:flutter_snaptag_kiosk/verification/presentation/screen_root/verification_root.dart';
import 'package:flutter_snaptag_kiosk/presentation/global_shell.dart';
import 'package:flutter_snaptag_kiosk/setup/presentation/kiosk_components/screen_root/kiosk_components_root.dart';
import 'package:flutter_snaptag_kiosk/setup/presentation/event_preview/screen_root/event_preview_root.dart';
import 'package:flutter_snaptag_kiosk/presentation/kiosk_shell/kiosk_shell.dart';
import 'package:flutter_snaptag_kiosk/setup/presentation/maintenance/screen_root/maintenance_root.dart';
import 'package:flutter_snaptag_kiosk/presentation/home/roots/home_root.dart';
import 'package:flutter_snaptag_kiosk/setup/presentation/payment_history/screen_root/payment_history_root.dart';
import 'package:flutter_snaptag_kiosk/setup/presentation/main/screen_root/setup_main_root.dart';
import 'package:flutter_snaptag_kiosk/presentation/test/unit_test_screen.dart';
import 'package:flutter_snaptag_kiosk/presentation/payment/roots/payment_root.dart';
import 'package:flutter_snaptag_kiosk/presentation/print/roots/print_process_root.dart';
import 'package:go_router/go_router.dart';

part 'router.g.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

final GlobalKey<NavigatorState> globalNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'global');

@TypedShellRoute<GlobalShellRouteData>(
  routes: [
    TypedGoRoute<SetupMainRouteData>(
      path: '/setup',
      routes: [
        TypedGoRoute<EventPreviewRouteData>(path: 'event-preview'),
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
    return const NoTransitionPage(
      child: SetupMainRoot(),
    );
  }
}

class PaymentHistoryRouteData extends GoRouteData with _$PaymentHistoryRouteData {
  const PaymentHistoryRouteData();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return const NoTransitionPage(
      child: PaymentHistoryRoot(),
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
      child: const KioskComponentsRoot(),
    );
  }
}

class EventPreviewRouteData extends GoRouteData with _$EventPreviewRouteData {
  const EventPreviewRouteData();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return NoTransitionPage(
      child: const EventPreviewRoot(),
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
      child: const HomeRoot(),
    );
  }
}

class CodeVerificationRouteData extends GoRouteData with _$CodeVerificationRouteData {
  const CodeVerificationRouteData();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return const NoTransitionPage(
      child: VerificationRoot(),
    );
  }
}

class PhotoCardPreviewRouteData extends GoRouteData with _$PhotoCardPreviewRouteData {
  const PhotoCardPreviewRouteData();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return NoTransitionPage(
      child: const PaymentRoot(),
    );
  }
}

class PrintProcessRouteData extends GoRouteData with _$PrintProcessRouteData {
  const PrintProcessRouteData();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return NoTransitionPage(
      child: const PrintProcessRoot(),
    );
  }
}

class MaintenanceRouteData extends GoRouteData with _$MaintenanceRouteData {
  const MaintenanceRouteData();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return NoTransitionPage(
      child: const MaintenanceRoot(),
    );
  }
}
