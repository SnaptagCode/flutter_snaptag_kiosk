import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'front_photo_list.g.dart';

@riverpod
class FrontPhotoList extends _$FrontPhotoList {
  @override
  List<FrontPhotoPath> build() => [];

  Future<void> fetch(int id) async {
    try {
      final NominatedPhotoList response = await ref.read(kioskRepositoryProvider).getFrontPhotoList(id);
      final data = await saveImages(response);
      state = data;
    } catch (e) {
      state = [];
    }
  }

  Future<List<FrontPhotoPath>> saveImages(NominatedPhotoList photoList) async {
    final List<FrontPhotoPath> frontPhotoPaths = [];
    for (var photo in photoList.list) {
      try {
        final fileName = '${photo.id}_${photo.embeddingProductId}';
        final filePath =
            await ref.read(imageStorageProvider).saveImage(DirectoryPaths.frontImages, photo.embeddedUrl, fileName);

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
