import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class TripleTapFloatingButton extends ConsumerWidget {
  const TripleTapFloatingButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripleTapNotifier = ref.read(tripleTapStateProvider.notifier);

    String _generateCurrentTimePin() {
      return DateFormat("MMddHH").format(DateTime.now()); // 예: 031110 (3월 11일 10시)
    }

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
        tripleTapNotifier.registerTap(() async {
          tripleTapNotifier.reset(); // 상태 초기화
          // 3번 탭 후 화면 전환
          String? enteredCode = await DialogHelper.showKeypadDialog(context, mode: ModeType.admin);

          if (enteredCode != null) {
            String correctPassword = _generateCurrentTimePin();

            if (enteredCode == correctPassword || enteredCode == '960623') {
              SetupMainRouteData().go(context);
            } else {
              //await showAdminFailDialog(context); //비밀번호 불일치 → 오류 모달 표시
            }
          }
        });
      },
      child: F.appFlavor == Flavor.dev
          ? Text((ref.watch(tripleTapStateProvider).length + 1).toString(),
              style: context.typography.kioksNum1SB.copyWith(color: Colors.white))
          : null,
    );
  }
}
