import 'dart:io';

import 'package:dio/dio.dart' as d show Dio, Options, ResponseType;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:path/path.dart' as path;
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

  static const String _imageDirectory = 'FrontImages';
  String get _directoryPath => path.join(Directory.current.path, _imageDirectory);

  Future<void> ensureDirectoryExists() async {
    final directory = Directory(_directoryPath);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
  }

  Future<void> saveImage(String imageUrl, String fileName) async {
    try {
      await ensureDirectoryExists();

      final response = await d.Dio().get<List<int>>(
        imageUrl,
        options: d.Options(
          responseType: d.ResponseType.bytes, // 바이너리 데이터로 받도록 설정
        ),
      );
      logger.d('이미지 다운로드 완료: ${response}');
      if (response.statusCode != 200) {
        throw Exception('이미지 다운로드 실패: ${response.statusCode}');
      }

      final file = File(path.join(_directoryPath, fileName));
      await file.writeAsBytes(response.data!);
      logger.d('이미지가 저장되었습니다: ${file.path}');
    } catch (e) {
      throw Exception('이미지 저장 중 오류 발생: $e');
    }
  }

  String? getImagePath(String fileName) {
    return path.join(_directoryPath, fileName);
  }

  Future<void> clearImages() async {
    try {
      final directory = Directory(_directoryPath);
      if (await directory.exists()) {
        await directory.delete(recursive: true);
      }
    } catch (e) {
      throw Exception('이미지 삭제 중 오류 발생: $e');
    }
  }
}
