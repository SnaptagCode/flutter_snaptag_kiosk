import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';

class TripleTapFloatingButton extends ConsumerWidget {
  const TripleTapFloatingButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripleTapNotifier = ref.read(tripleTapStateProvider.notifier);

    return FloatingActionButton(
      heroTag: null,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      splashColor: Colors.transparent,
      hoverElevation: 0.0,
      focusElevation: 0.0,
      highlightElevation: 0.0,
      backgroundColor:
          F.appFlavor == Flavor.dev ? context.kioskColors.buttonColor.withOpacity(0.3) : Colors.transparent,
      elevation: 0.0,
      onPressed: () {
        tripleTapNotifier.registerTap(() {
          tripleTapNotifier.reset(); // 상태 초기화
          // 3번 탭 후 화면 전환
          SetupMainRouteData().go(context);
        });
      },
      child: F.appFlavor == Flavor.dev
          ? Text((ref.watch(tripleTapStateProvider).length + 1).toString(),
              style: context.typography.kioksNum1SB.copyWith(color: Colors.white))
          : null,
    );
  }
}
