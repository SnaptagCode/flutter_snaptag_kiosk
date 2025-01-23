import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';

class TripleTapFloatingButton extends ConsumerWidget {
  const TripleTapFloatingButton({required this.isSetup, super.key});
  final bool isSetup;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripleTapNotifier = ref.read(tripleTapStateProvider.notifier);

    return Theme(
      data: context.theme.copyWith(splashFactory: NoSplash.splashFactory),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          FloatingActionButton(
            heroTag: null,
            onPressed: () {
              tripleTapNotifier.registerTap(() {
                tripleTapNotifier.reset(); // 상태 초기화
                exit(0); // 3번 탭 후 종료
              });
            },
            elevation: F.appFlavor == Flavor.dev ? null : 0.0,
            backgroundColor: F.appFlavor == Flavor.dev ? null : Colors.transparent,
            child: F.appFlavor == Flavor.dev ? const Icon(Icons.minimize) : const SizedBox.shrink(),
          ),
          FloatingActionButton(
            heroTag: null,
            onPressed: () {
              tripleTapNotifier.registerTap(() {
                tripleTapNotifier.reset(); // 상태 초기화
                // 3번 탭 후 화면 전환
                isSetup ? PhotoCardUploadRouteData().go(context) : KioskInfoRouteData().go(context);
              });
            },
            elevation: F.appFlavor == Flavor.dev ? null : 0.0,
            backgroundColor: F.appFlavor == Flavor.dev ? null : Colors.transparent,
            child: F.appFlavor == Flavor.dev ? const Icon(Icons.drive_file_move_rounded) : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
