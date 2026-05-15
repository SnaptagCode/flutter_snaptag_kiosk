export 'package:flutter_snaptag_kiosk/domain/models/page_print_type.dart';

import 'package:flutter_snaptag_kiosk/domain/models/page_print_type.dart';
import 'package:flutter_snaptag_kiosk/presentation/kiosk_shell/kiosk_info_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_snaptag_kiosk/core/core.dart';
import 'package:flutter_snaptag_kiosk/presentation/core/slack_log_provider.dart';

part 'page_print_notifier.g.dart';

@Riverpod(keepAlive: true)
class PagePrint extends _$PagePrint {
  @override
  PagePrintType build() => PagePrintType.none;

  void switchType() {
    state = state == PagePrintType.double ? PagePrintType.single : PagePrintType.double;
    ref.read(slackLogServiceProvider).sendBroadcastLogWithKey(
        state == PagePrintType.single ? InfoKey.cardPrintModeSwitchSingle.key : InfoKey.cardPrintModeSwitchDuplex.key);
  }

  void set(PagePrintType type) {
    final machineId = ref.read(kioskInfoServiceProvider)?.kioskMachineId ?? 0;
    if (type != state) {
      print("chaneg Printe type : $type");
      if (type == PagePrintType.double && machineId != 0) {
        ref.read(slackLogServiceProvider).sendBroadcastLogWithKey(InfoKey.cardPrintModeSwitchDuplex.key);
      }
    }
    state = type;
  }
}
