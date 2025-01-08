import 'package:flutter_snaptag_kiosk/core/constants/directory_paths.dart';
import 'package:flutter_snaptag_kiosk/data/data.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'front_images_provider.g.dart';

@riverpod
class FrontImages extends _$FrontImages {
  @override
  Future<void> build() async {
    return _fetchAndSaveImages();
  }

  Future<void> _fetchAndSaveImages() async {
    try {
      final yamlRepo = ref.read(storageServiceProvider);
      final currentSettings = yamlRepo.settings;

      if (currentSettings.kioskEventId == 0) {
        throw KioskException('이벤트 ID가 설정되지 않았습니다.');
      }

      // API를 통해 이미지 목록 가져오기
      final kioskRepo = ref.read(kioskRepositoryProvider);
      final response = await kioskRepo.getFrontPhotoList(
        currentSettings.kioskEventId,
      );

      // 이미지 저장소 준비
      final imageStorage = ref.read(imageStorageProvider);

      // 각 이미지 다운로드 및 저장
      for (final photo in response.list) {
        final fileName = 'front_${photo.id}.jpg';
        await imageStorage.saveImage(DirectoryPaths.frontImages, photo.embeddedUrl, fileName);
      }
    } catch (e) {
      throw KioskException(e is KioskException ? e.message : '이미지 동기화 중 오류가 발생했습니다.\n오류: $e');
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    await _fetchAndSaveImages();
    state = const AsyncValue.data(null);
  }
}
