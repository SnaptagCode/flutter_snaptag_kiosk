import 'dart:async';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:flutter_snaptag_kiosk/presentation/home/machine_file_handler.dart';
import 'package:flutter_snaptag_kiosk/presentation/kiosk_shell/kiosk_info_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'maintenance_polling_provider.g.dart';

/// 유지보수(점검·파일 동기화) 폴링 전담. 홈 화면 수명에 묶여 동작한다.
/// View에 emit할 상태가 없는 사이드이펙트 루프라 void 프로바이더로 두고,
/// 화면은 keep-alive 목적으로만 구독한다.
@riverpod
void maintenancePolling(Ref ref) {
  Timer? timer;
  var isChecking = false;

  Future<void> check() async {
    try {
      final kioskInfo = ref.read(kioskInfoServiceProvider);
      if (kioskInfo == null) return;

      final response = await ref.read(kioskRepositoryProvider).getMachineMaintenance(
            machineId: kioskInfo.kioskMachineId,
          );

      unawaited(ref.read(machineFileHandlerProvider).handleFileTasks(
            logPaths: response,
            downloads: null,
            machineId: kioskInfo.kioskMachineId,
          ));
    } catch (e) {
      log('[MachineCheck] 점검 확인 실패: $e');
    }
  }

  timer = Timer.periodic(const Duration(seconds: 3), (_) async {
    // 직전 확인이 끝나지 않았으면 이번 tick은 건너뛴다
    if (isChecking) return;
    isChecking = true;
    try {
      await check();
    } finally {
      isChecking = false;
    }
  });

  ref.onDispose(() => timer?.cancel());
}
