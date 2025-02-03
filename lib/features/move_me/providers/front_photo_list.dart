import 'dart:io';
import 'dart:math';

import 'package:flutter_snaptag_kiosk/lib.dart';
import 'package:path/path.dart' as path;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'front_photo_list.g.dart';

@riverpod
class FrontPhotoList extends _$FrontPhotoList {
  @override
  List<String> build() {
    final directory = Directory(DirectoryPaths.frontImages.buildPath);
    // 디렉토리가 존재하지 않으면 빈 리스트 반환
    if (!directory.existsSync()) {
      return [];
    }

    try {
      // 디렉토리 내 모든 파일 가져오기
      final files = directory
          .listSync()
          .whereType<File>() // 파일만 필터링
          .where((file) {
        // 이미지 파일 확장자 체크
        final extension = file.path.toLowerCase();
        return extension.endsWith('.jpg') || extension.endsWith('.jpeg') || extension.endsWith('.png');
      });

      // FrontPhotoPath 객체로 변환
      return files.map((file) {
        // 파일명이 '{id}_{code}_{embeddingProductId}.확장자' 형식인 경우
        // 파일명에서 id, code embeddingProductId 추출 시도
        final fileName = path.basenameWithoutExtension(file.path);
        final parts = fileName.split('_');
        if (parts.length == 3) {
          final id = int.tryParse(parts[0]);
          final code = int.tryParse(parts[1]);
          final embeddingProductId = int.tryParse(parts[2]);
          if (id != null && code != null && embeddingProductId != null) {
            return file.path;
          } else {
            // exception
            throw Exception('Invalid file name format: $fileName');
          }
        } else {
          // exception
          throw Exception('Invalid file name format: $fileName');
        }
      }).toList();
    } catch (e) {
      logger.e('이미지 목록을 불러오는 중 오류가 발생했습니다: $e');
      return [];
    }
  }

  Future<void> fetch() async {
    try {
      await ref.read(imageStorageProvider).clearDirectory(DirectoryPaths.frontImages);

      final yamlRepo = ref.read(storageServiceProvider);
      final currentSettings = yamlRepo.settings;

      if (currentSettings.kioskEventId == 0) {
        throw KioskException(KioskErrorType.missingEventId);
      }
      // API를 통해 이미지 목록 가져오기
      final kioskRepo = ref.read(kioskRepositoryProvider);
      final NominatedPhotoList response = await kioskRepo.getFrontPhotoList(currentSettings.kioskEventId);
      final data = await _saveImages(response);
      state = data;
    } catch (e) {
      state = [];
    }
  }

  Future<List<String>> _saveImages(NominatedPhotoList photoList) async {
    final List<String> frontPhotoPaths = [];
    // 이미지 저장소 준비
    final imageStorage = ref.read(imageStorageProvider);
    // 각 이미지 다운로드 및 저장
    for (var photo in photoList.list) {
      try {
        // '{id}_{code}_{embeddingProductId}.확장자' 형식
        final fileName = '${photo.id}_${photo.code}_${photo.embeddingProductId}';
        final filePath = await imageStorage.saveImage(DirectoryPaths.frontImages, photo.embedUrl, fileName);

        frontPhotoPaths.add(filePath);
      } catch (e) {
        logger.e('이미지 저장 중 오류가 발생했습니다: $e');
      }
    }
    return frontPhotoPaths;
  }

  Future<({String path, int id, int code, int embeddingProductId})> getRandomPhoto() async {
    if (state.isEmpty) {
      throw Exception('No front images available');
    }

    final random = Random();
    final randomPath = state[random.nextInt(state.length)];

    try {
      // 파일명에서 정보 추출
      final result = _getPhotoInfo(randomPath);

      if (result != null) {
        return (
          id: result.id,
          code: result.code,
          embeddingProductId: result.embeddingProductId,
          path: randomPath,
        );
      }

      throw Exception('Invalid file name format: $randomPath');
    } catch (e) {
      logger.e('이미지 정보 추출 중 오류가 발생했습니다: $e');
      throw Exception('Failed to get random photo');
    }
  }

  // 특정 이미지의 정보를 추출하는 메서드
  ({int id, int code, int embeddingProductId})? _getPhotoInfo(String imagePath) {
    try {
      final fileName = path.basenameWithoutExtension(imagePath);
      final parts = fileName.split('_');

      if (parts.length == 3) {
        final id = int.tryParse(parts[0]);
        final code = int.tryParse(parts[1]);
        final embeddingProductId = int.tryParse(parts[2]);

        if (id != null && code != null && embeddingProductId != null) {
          return (
            id: id,
            code: code,
            embeddingProductId: embeddingProductId,
          );
        }
      }
      throw Exception('Invalid file name format: $fileName');
    } catch (e) {
      logger.e('이미지 정보 추출 중 오류가 발생했습니다: $e');
      return null;
    }
  }
}
