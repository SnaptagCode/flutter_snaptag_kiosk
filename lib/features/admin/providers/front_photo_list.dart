import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'front_photo_list.g.dart';

@riverpod
class FrontPhotoList extends _$FrontPhotoList {
  @override
  List<FrontPhotoPath> build() => [];

  Future<void> fetch() async {
    try {
      final yamlRepo = ref.read(storageServiceProvider);
      final currentSettings = yamlRepo.settings;

      if (currentSettings.kioskEventId == 0) {
        throw KioskException(KioskErrorType.missingEventId);
      }
      // API를 통해 이미지 목록 가져오기
      final kioskRepo = ref.read(kioskRepositoryProvider);
      final NominatedPhotoList response = await kioskRepo.getFrontPhotoList(currentSettings.kioskEventId);
      final data = await saveImages(response);
      state = data;
    } catch (e) {
      state = [];
    }
  }

  Future<List<FrontPhotoPath>> saveImages(NominatedPhotoList photoList) async {
    final List<FrontPhotoPath> frontPhotoPaths = [];
    // 이미지 저장소 준비
    final imageStorage = ref.read(imageStorageProvider);
    // 각 이미지 다운로드 및 저장
    for (var photo in photoList.list) {
      try {
        final fileName = '${photo.id}_${photo.embeddingProductId}';
        final filePath = await imageStorage.saveImage(DirectoryPaths.frontImages, photo.embeddedUrl, fileName);

        frontPhotoPaths.add(FrontPhotoPath(localPath: filePath, photo: photo));
      } catch (e) {
        logger.e('이미지 저장 중 오류가 발생했습니다: $e');
      }
    }
    return frontPhotoPaths;
  }

  Future<void> clearImages() async {
    try {
      await ref.read(imageStorageProvider).clearDirectory(DirectoryPaths.frontImages);
      state = [];
    } catch (e) {
      state = [];
    }
  }
}
