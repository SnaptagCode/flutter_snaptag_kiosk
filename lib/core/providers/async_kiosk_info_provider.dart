import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'async_kiosk_info_provider.g.dart';

@riverpod
class AsyncKioskInfo extends _$AsyncKioskInfo {
  @override
  Future<KioskMachineInfo> build() async {
    return _fetchAndUpdateKioskInfo();
  }

  Future<KioskMachineInfo> _fetchAndUpdateKioskInfo({int? machineId}) async {
    try {
      // kioskMachineId가 없는 경우 예외 발생
      if (machineId == null) {
        throw Exception('No kiosk machine id available');
      }

      // API를 통해 최신 정보 가져오기
      final kioskRepo = ref.read(kioskRepositoryProvider);
      await kioskRepo.healthCheck();
      final response = await kioskRepo.getKioskMachineInfo(
        machineId,
      );

      // API 응답으로 settings 업데이트
      ref.read(kioskInfoServiceProvider.notifier).saveSettings(response);

      ref.read(frontPhotoListProvider.notifier).fetch();

      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(() => _fetchAndUpdateKioskInfo());
  }

  /// 새로운 머신 ID로 업데이트 후 새로고침
  Future<void> refreshWithMachineId(int machineId) async {
    state = await AsyncValue.guard(() => _fetchAndUpdateKioskInfo(machineId: machineId));
  }
}
