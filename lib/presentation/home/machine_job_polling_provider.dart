import 'dart:async';

import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:flutter_snaptag_kiosk/presentation/kiosk_shell/kiosk_info_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'machine_job_polling_provider.g.dart';

sealed class MachineJobState {
  const MachineJobState();
}

final class MachineJobIdle extends MachineJobState {
  const MachineJobIdle();
}

final class MachineJobDetected extends MachineJobState {
  final MachineJobPollingResponse response;
  const MachineJobDetected(this.response);
}

/// 머신 잡(자동 환불) 폴링 전담. 타이머·재시도·선점·판정만 담당하며
/// 다이얼로그 등 BuildContext가 필요한 처리는 상태로 emit해 View에 위임한다.
@riverpod
class MachineJobPolling extends _$MachineJobPolling {
  Timer? _timer;
  bool _isChecking = false;
  bool _disposed = false;

  @override
  MachineJobState build() {
    ref.onDispose(() {
      _disposed = true;
      _timer?.cancel();
    });
    _startTimer();
    return const MachineJobIdle();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) => _tick());
  }

  Future<void> _tick() async {
    // 직전 확인이 끝나지 않았으면 이번 tick은 건너뛴다
    if (_isChecking) return;
    _isChecking = true;
    try {
      await _check();
    } finally {
      _isChecking = false;
    }
  }

  Future<void> _check() async {
    final kioskInfo = ref.read(kioskInfoServiceProvider);
    if (kioskInfo == null) return;

    const maxRetries = 3;
    MachineJobPollingResponse? response;
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        response = await ref.read(kioskRepositoryProvider).getMachineJobPolling(kioskInfo.kioskMachineId);
        break;
      } catch (e) {
        if (attempt == maxRetries) {
          SlackLogService().sendErrorLogToSlack(
            '[${kioskInfo.kioskMachineName} (${kioskInfo.kioskMachineId})] 환불 상태확인 실패 ($maxRetries회 시도 실패): $e',
          );
          return; // 다음 tick까지 대기
        }
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }

    if (_disposed || response == null || !response.exists) return;

    // job 발견 → 주기 polling 중단 후 선점
    _timer?.cancel();
    try {
      // 선점: 다른 처리와 중복되지 않도록 서버에 잠금
      await ref.read(kioskRepositoryProvider).pickMachineJob(response.printJobId!);
    } catch (e) {
      await _failQuietly(response.printJobId, '선점 실패: $e');
      if (!_disposed) _startTimer();
      return;
    }

    // 상태 emit → View가 카드삽입 다이얼로그를 처리
    if (!_disposed) state = MachineJobDetected(response);
  }

  /// View: 사용자가 환불을 취소(또는 타임아웃)
  Future<void> cancelJob(MachineJobPollingResponse response) async {
    await _failQuietly(response.printJobId, '사용자 취소');
    resume();
  }

  /// View: 환불 흐름 종료 → idle 복귀 후 polling 재개
  void resume() {
    if (_disposed) return;
    state = const MachineJobIdle();
    _startTimer();
  }

  Future<void> _failQuietly(int? printJobId, String reason) async {
    if (printJobId == null) return;
    try {
      await ref.read(kioskRepositoryProvider).failMachineJob(
            printJobId: printJobId,
            failureReason: reason,
          );
    } catch (_) {}
  }
}
