import 'dart:io';

import 'package:dio/dio.dart' as dio show Dio, Options, ResponseType;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_snaptag_kiosk/core/constants/constants.dart';
import 'package:flutter_snaptag_kiosk/core/errors/errors.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'file_system_service.dart';

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

  String _getFileExtensionFromUrl(String url) {
    final uri = Uri.parse(url);
    final path = uri.path;
    final lastDot = path.lastIndexOf('.');
    if (lastDot != -1) {
      return path.substring(lastDot);
    }
    return '.png'; // 기본값
  }

  String _getFileExtensionFromContentType(String? contentType) {
    logger.d('Content-Type: $contentType');
    switch (contentType?.toLowerCase()) {
      case 'image/jpeg':
        return '.jpg';
      case 'image/png':
        return '.png';
      case 'image/gif':
        return '.gif';
      case 'image/webp':
        return '.webp';
      default:
        return '.png'; // 기본값
    }
  }

  Future<String> saveImage(DirectoryPaths directory, String imageUrl, String fileName) async {
    try {
      await _fileSystem.ensureDirectoryExists(directory);

      final response = await dio.Dio().get<List<int>>(
        imageUrl,
        options: dio.Options(responseType: dio.ResponseType.bytes),
      );

      if (response.statusCode != 200) {
        throw StorageException(
          StorageErrorType.downloadError,
          path: imageUrl,
          originalError: 'Status code: ${response.statusCode}',
        );
      }
      final contentType = response.headers.value('content-type');
      final extension =
          contentType != null ? _getFileExtensionFromContentType(contentType) : _getFileExtensionFromUrl(imageUrl);

      final fullFileName = '$fileName$extension';
      final filePath = _fileSystem.getFilePath(directory, fileName: fullFileName);
      final file = File(filePath);
      await file.writeAsBytes(response.data!);
      logger.d('이미지가 저장되었습니다: ${file.path}');
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
        final filePath = await saveImage(directory, photo.embeddedUrl, fileName);
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
