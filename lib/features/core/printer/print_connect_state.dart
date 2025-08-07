import 'package:flutter_snaptag_kiosk/data/datasources/cache/kiosk_info_service.dart';
import 'package:flutter_snaptag_kiosk/data/datasources/remote/slack_log_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'print_connect_state.g.dart';

enum PrintConnectState {
  connected,
  disconnected,
  pending,
}

@Riverpod(keepAlive: true)
class PrintConnect extends _$PrintConnect {
  @override
  PrintConnectState build() {
    return PrintConnectState.pending;
  }

  /// 프린터 연결 상태 업데이트
  /// @param state 연결 상태
  void update(PrintConnectState state) {
    final machineId = ref.read(kioskInfoServiceProvider)?.kioskMachineId ?? 0;

    if (this.state == state || state == PrintConnectState.pending) {
      // 현재 상태와 동일하거나, 상태가 'pending'인 경우
      // 'pending' 상태는 연결 상태가 아직 결정되지 않은 경우이므로, 아무 작업도 하지 않음
      return;
    }

    SlackLogService().sendLogToSlack('MachineId : $machineId Printer ${state.name}');

    this.state = state;
  }
}
