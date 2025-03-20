import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:go_router/go_router.dart';

class KioskNavigatorButton extends ConsumerWidget {
  const KioskNavigatorButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final currentPath = GoRouterState.of(context).fullPath;
    if (currentPath != PhotoCardUploadRouteData().location) {
      return const HomeButton();
    } else {
      return const LanguageSwitcher();
    }
  }
}

// ...existing code...
