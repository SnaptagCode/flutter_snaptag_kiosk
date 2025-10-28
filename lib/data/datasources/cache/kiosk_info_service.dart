import 'dart:async';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'kiosk_info_service.g.dart';

@Riverpod(keepAlive: true)
class KioskInfoService extends _$KioskInfoService {
  Timer? _periodicTimer;
  int? _cachedMachineId;
  int? _cachedKioskEventId;

  @override
  KioskMachineInfo? build() {
    // 서비스가 dispose될 때 타이머 취소
    ref.onDispose(() {
      _cancelTimer();
    });

    return null;
  }

  Future<KioskMachineInfo> _fetchAndUpdateKioskInfo({int? machineId}) async {
    try {
      // kioskMachineId가 없는 경우 예외 발생
      if (machineId == null) {
        throw Exception('No kiosk machine id available');
      }
      state = KioskMachineInfo();
      // API를 통해 최신 정보 가져오기
      final kioskRepo = ref.read(kioskRepositoryProvider);

      final response = await kioskRepo.getKioskMachineInfo(
        machineId,
      );

      state = response;

      ref.read(frontPhotoListProvider.notifier).fetch();

      // 캐시된 값들 업데이트
      _cachedMachineId = machineId;
      _cachedKioskEventId = response.kioskEventId;

      // 응답을 받은 후 10분마다 실행되는 타이머 시작
      _startPeriodicTimer();

      return response;
    } catch (e) {
      ref.invalidateSelf();
      rethrow;
    }
  }

  /// 새로운 머신 ID로 업데이트 후 새로고침
  Future<void> refreshWithMachineId(int machineId) async {
    state = await _fetchAndUpdateKioskInfo(machineId: machineId);
  }

  /// 10분마다 실행되는 주기적 타이머 시작
  void _startPeriodicTimer() {
    // 기존 타이머가 있다면 취소
    _periodicTimer?.cancel();

    SlackLogService().sendLogToSlack("Periodic _startPeriodicTimer");

    // 10분마다 실행되는 새로운 타이머 시작
    _periodicTimer = Timer.periodic(
      const Duration(seconds: 10),
      (timer) async {
        try {
          // 캐시된 값들 사용 (순환 의존성 방지)
          final kioskEventId = _cachedKioskEventId ?? 0;
          final machineId = _cachedMachineId ?? 0;
          final cardCountState = ref.read(cardCountProvider);

          if (kioskEventId != 0 && machineId != 0 && cardCountState.currentCount > 0) {
            await ref.read(kioskRepositoryProvider).checkKioskAlive(
                  kioskEventId: kioskEventId,
                  machineId: machineId,
                  remainingSingleSidedCount: cardCountState.currentCount,
                );
          }
          SlackLogService().sendLogToSlack("Periodic timer: $kioskEventId, $machineId, ${cardCountState.currentCount}");
        } catch (e) {
          // 에러가 발생해도 타이머는 계속 실행
          print('Periodic timer error: $e');
          SlackLogService().sendLogToSlack("Periodic timer error: $e");
        }
      },
    );
  }

  /// 타이머 취소
  void _cancelTimer() {
    _periodicTimer?.cancel();
    _periodicTimer = null;
  }
}
