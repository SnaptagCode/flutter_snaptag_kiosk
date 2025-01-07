import 'dart:io';

import 'package:dio/dio.dart' as dio show Dio, Options, ResponseType;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_snaptag_kiosk/core/constants/constants.dart';
import 'package:flutter_snaptag_kiosk/core/exceptions/exceptions.dart';
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

  Future<void> saveImage(DirectoryPaths directory, String imageUrl, String fileName) async {
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

      final filePath = _fileSystem.getFilePath(directory, fileName);
      final file = File(filePath);
      await file.writeAsBytes(response.data!);
      logger.d('이미지가 저장되었습니다: ${file.path}');
    } catch (e, stack) {
      throw StorageException(
        StorageErrorType.saveError,
        path: _fileSystem.getFilePath(directory, fileName),
        originalError: e,
        stackTrace: stack,
      );
    }
  }
}
