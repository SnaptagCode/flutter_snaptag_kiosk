import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_snaptag_kiosk/features/move_me/screens/global_shell.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:go_router/go_router.dart';
import 'package:material_components/material_screen.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'router.dart';

part 'go_router.g.dart';

@riverpod
GoRouter router(Ref ref) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: SetupMainRouteData().location,
    routes: $appRoutes,
    debugLogDiagnostics: true,
  );
}
