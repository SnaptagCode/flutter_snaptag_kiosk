import 'package:flutter_snaptag_kiosk/presentation/kiosk_shell/kiosk_info_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';

part 'page_print_provider.g.dart';

@Riverpod(keepAlive: true)
class PagePrint extends _$PagePrint {
  @override
  PagePrintType build() => PagePrintType.none; //단면_양면 기능 적용시 none

  void switchType() {
    state = state == PagePrintType.double ? PagePrintType.single : PagePrintType.double;
    SlackLogService().sendBroadcastLogToSlack(
        state == PagePrintType.single ? InfoKey.cardPrintModeSwitchSingle.key : InfoKey.cardPrintModeSwitchDuplex.key);
  }

  void set(PagePrintType type) {
    final machineId = ref.read(kioskInfoServiceProvider)?.kioskMachineId ?? 0;
    if (type != state) {
      print("chaneg Printe type : $type");
      if (type == PagePrintType.double && machineId != 0)
        SlackLogService().sendBroadcastLogToSlack(InfoKey.cardPrintModeSwitchDuplex.key);
    }
    state = type;
  }
}

enum PagePrintType {
  single, // 양면 인쇄
  double, // 단면 인쇄
  none // 인쇄모드 미선택
}
