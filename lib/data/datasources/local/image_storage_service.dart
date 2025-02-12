import 'dart:io';

import 'package:dio/dio.dart' as dio show Response;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'image_storage_service.g.dart';

@Riverpod(keepAlive: true)
ImageStorageService imageStorage(Ref ref) {
  throw UnimplementedError('Image storage not initialized');
}

class ImageStorageService {
  ImageStorageService._();

  static Future<ImageStorageService> initialize() async {
    return ImageStorageService._();
  }

  final _fileSystem = FileSystemService.instance;

  Future<String> saveImage(DirectoryPaths directory, String imageUrl, String fileName) async {
    try {
      await _fileSystem.ensureDirectoryExists(directory);
      final dio.Response response = await ImageHelper().getImageBytes(imageUrl);
      final contentType = response.headers.value('content-type');
      final extension = contentType != null
          ? ImageHelper().getFileExtensionFromContentType(contentType)
          : ImageHelper().getFileExtensionFromUrl(imageUrl);

      final fullFileName = '$fileName$extension';
      final filePath = _fileSystem.getFilePath(directory, fileName: fullFileName);
      final file = File(filePath);
      await file.writeAsBytes(response.data!);
      return file.path;
    } catch (e, stack) {
      throw StorageException(
        StorageErrorType.saveError,
        path: _fileSystem.getFilePath(directory, fileName: fileName),
        originalError: e,
        stackTrace: stack,
      );
    }
  }

  Future<List<String>> saveImages(DirectoryPaths directory, NominatedPhotoList photoList) async {
    final List<String> filePaths = [];
    for (var photo in photoList.list) {
      try {
        final fileName = '${photo.id}_${photo.embeddingProductId}';
        final filePath = await saveImage(directory, photo.embedUrl, fileName);
        filePaths.add(filePath);
      } catch (e) {
        logger.e('이미지 저장 중 오류가 발생했습니다: $e');
      }
    }
    return filePaths;
  }

  //clearDirectory
  Future<void> clearDirectory(DirectoryPaths directory) async {
    try {
      await _fileSystem.clearDirectory(directory);
    } catch (e) {
      throw StorageException(
        StorageErrorType.deleteError,
      );
    }
  }
}
