import 'package:flutter_snaptag_kiosk/core/constants/constants.dart';
import 'package:flutter_snaptag_kiosk/data/data.dart';
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
        throw KioskException('키오스크 ID가 설정되지 않았습니다.\n'
            '다음 경로의 설정 파일을 확인해주세요:\n'
            '${yamlRepo.filePath}');
      }

      // API를 통해 최신 정보 가져오기
      final kioskRepo = ref.read(kioskRepositoryProvider);
      final response = await kioskRepo.getKioskMachineInfo(
        currentSettings.kioskMachineId,
      );

      // API 응답으로 yaml 파일 업데이트

      final imageStorage = ref.read(imageStorageProvider);
      await yamlRepo.saveSettings(response);
      if (response.mainImageUrl.isNotEmpty) {
        final body = await imageStorage.saveImage(DirectoryPaths.settings, response.mainImageUrl, 'body');
        await yamlRepo.updateImagePaths(bodyPath: body);
      }
      if (response.topBannerUrl.isNotEmpty) {
        final header = await imageStorage.saveImage(DirectoryPaths.settings, response.topBannerUrl, 'header');
        await yamlRepo.updateImagePaths(headerPath: header);
      }

      return response;
    } catch (e) {
      throw KioskException(e is KioskException ? e.message : '키오스크 정보를 가져오는데 실패했습니다.\n오류: $e');
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = AsyncValue.data(await _fetchAndUpdateKioskInfo());
  }
}
