import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'kiosk_info_service.g.dart';

@Riverpod(keepAlive: true)
class KioskInfoService extends _$KioskInfoService {
  @override
  KioskMachineInfo build() {
    return KioskMachineInfo();
  }

  KioskMachineInfo _settings = KioskMachineInfo();

  /// 현재 Kiosk 설정 반환
  KioskMachineInfo get settings => _settings;

  /// 설정값 저장 (메모리 캐시)
  void saveSettings(KioskMachineInfo info) {
    _settings = info;
  }

  Future<KioskMachineInfo> _fetchAndUpdateKioskInfo({int? machineId}) async {
    try {
      // kioskMachineId가 없는 경우 예외 발생
      if (machineId == null) {
        throw Exception('No kiosk machine id available');
      }
      saveSettings(KioskMachineInfo());
      // API를 통해 최신 정보 가져오기
      final kioskRepo = ref.read(kioskRepositoryProvider);

      final response = await kioskRepo.getKioskMachineInfo(
        machineId,
      );

      // API 응답으로 settings 업데이트
      ref.read(kioskInfoServiceProvider.notifier).saveSettings(response);

      ref.read(frontPhotoListProvider.notifier).fetch();

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
}
