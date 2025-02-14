import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart' as dio;
import 'package:flutter_snaptag_kiosk/core/utils/random/random_photo_util.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'front_photo_list.g.dart';

@Riverpod(keepAlive: true)
class FrontPhotoList extends _$FrontPhotoList {
  @override
  List<NominatedPhoto> build() {
    return [];
  }

  Future<void> fetch() async {
    try {
      await clearDirectory();

      final kioskEventId = ref.read(kioskInfoServiceProvider.notifier).settings.kioskEventId;

      if (kioskEventId == 0) {
        throw Exception('No kiosk event id available');
      }
      // API를 통해 이미지 목록 가져오기
      final kioskRepo = ref.read(kioskRepositoryProvider);
      final NominatedPhotoList response = await kioskRepo.getFrontPhotoList(kioskEventId);
      final data = await saveImages(response.list);
      state = data;
    } catch (e) {
      state = [];
    }
  }

  Future<NominatedPhoto> getRandomPhoto() async {
    if (state.isEmpty) {
      throw Exception('No front images available');
    }

    try {
      // 파일명에서 정보 추출
      final result = RandomPhotoUtil.getRandomPhotoByWeight(state);

      if (result != null) {
        return result;
      }

      throw Exception('Invalid file name format: ${result?.embedImage?.path}');
    } catch (e) {
      logger.e('이미지 정보 추출 중 오류가 발생했습니다: $e');
      throw Exception('Failed to get random photo');
    }
  }

  final _fileSystem = FileSystemService.instance;

  Future<List<NominatedPhoto>> saveImages(List<NominatedPhoto> photos) async {
    final List<NominatedPhoto> cacheList = [];

    await _fileSystem.ensureDirectoryExists(DirectoryPaths.frontImages);

    for (var photo in photos) {
      try {
        final dio.Response response = await ImageHelper().getImageBytes(photo.embedUrl);
        final contentType = response.headers.value('content-type');
        final extension = contentType != null
            ? ImageHelper().getFileExtensionFromContentType(contentType)
            : ImageHelper().getFileExtensionFromUrl(photo.embedUrl);

        final Uint8List bytes = Uint8List.fromList(response.data);
        final File file = File('${DirectoryPaths.frontImages.buildPath}/${photo.getFileName}$extension');

        await file.writeAsBytes(bytes); // 파일 저장

        cacheList.add(photo.copyWith(embedImage: file)); // File로 저장
      } catch (e, stack) {
        throw StorageException(
          StorageErrorType.saveError,
          path: '${DirectoryPaths.frontImages.buildPath}/${photo.embeddingProductId}: ${photo.embedUrl}',
          originalError: e,
          stackTrace: stack,
        );
      }
    }
    return cacheList;
  }

  Future<void> clearDirectory() async {
    try {
      await _fileSystem.clearDirectory(DirectoryPaths.frontImages);
    } catch (e) {
      throw StorageException(
        StorageErrorType.deleteError,
      );
    } finally {
      //갱신
      state = [];
    }
  }
}
