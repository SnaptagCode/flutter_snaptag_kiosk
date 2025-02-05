import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'async_kiosk_info_provider.g.dart';

@riverpod
class AsyncKioskInfo extends _$AsyncKioskInfo {
  @override
  Future<KioskMachineInfo> build() async {
    return _fetchAndUpdateKioskInfo();
  }

  Future<KioskMachineInfo> _fetchAndUpdateKioskInfo() async {
    try {
      final yamlRepo = ref.read(storageServiceProvider);

      // 먼저 파일 재로드
      await yamlRepo.reloadSettings();
      final currentSettings = yamlRepo.settings;

      // kioskMachineId가 없는 경우 예외 발생
      if (currentSettings.kioskMachineId == 0) {
        throw KioskException(KioskErrorType.missingMachineId);
      }

      // API를 통해 최신 정보 가져오기
      final kioskRepo = ref.read(kioskRepositoryProvider);
      await kioskRepo.healthCheck();
      final response = await kioskRepo.getKioskMachineInfo(
        currentSettings.kioskMachineId,
      );

      // API 응답으로 yaml 파일 업데이트
      await yamlRepo.saveSettings(response);

      await ref.read(frontPhotoListProvider.notifier).fetch();

      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = AsyncValue.data(await _fetchAndUpdateKioskInfo());
  }
}
