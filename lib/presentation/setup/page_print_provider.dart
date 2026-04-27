import 'package:flutter_snaptag_kiosk/core/common/log/app_log_service.dart';
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
    final label = state == PagePrintType.single ? '단면' : '양면';
    AppLogService.instance.info('인쇄 모드 전환: $label');
    SlackLogService().sendBroadcastLogToSlackWithKey(
        state == PagePrintType.single ? InfoKey.cardPrintModeSwitchSingle.key : InfoKey.cardPrintModeSwitchDuplex.key);
  }

  void set(PagePrintType type) {
    final machineId = ref.read(kioskInfoServiceProvider)?.kioskMachineId ?? 0;
    if (type != state) {
      final label = type == PagePrintType.single ? '단면' : type == PagePrintType.double ? '양면' : 'none';
      AppLogService.instance.info('인쇄 모드 설정: $label');
      if (type == PagePrintType.double && machineId != 0) {
        SlackLogService().sendBroadcastLogToSlackWithKey(InfoKey.cardPrintModeSwitchDuplex.key);
      }
    }
    state = type;
  }
}

enum PagePrintType {
  single, // 양면 인쇄
  double, // 단면 인쇄
  none // 인쇄모드 미선택
}
