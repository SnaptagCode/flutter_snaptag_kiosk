import 'dart:ffi';
import 'dart:io';
import 'dart:math';

import 'package:flutter/rendering.dart';
import 'package:flutter_snaptag_kiosk/core/utils/random/random_photo_util.dart';
import 'package:flutter_snaptag_kiosk/domain/entities/SeletedFrontPhoto.dart';
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

      // List<String> 로 변환 String : path
      return files
          .map((file) => RandomPhotoUtil.convertFromFileToObject(file.path)?.path)
          .where((path) => path != null)
          .cast<String>()
          .toList();
    } catch (e) {
      logger.e('이미지 목록을 불러오는 중 오류가 발생했습니다: $e');
      return [];
    }
  }

  Future<void> fetch() async {
    try {
      await ref.read(imageStorageProvider).clearDirectory(DirectoryPaths.frontImages);

      final kioskEventId = ref.read(storageServiceProvider).settings.kioskEventId;

      if (kioskEventId == 0) {
        throw Exception('No kiosk event id available');
      }
      // API를 통해 이미지 목록 가져오기
      final kioskRepo = ref.read(kioskRepositoryProvider);
      final NominatedPhotoList response = await kioskRepo.getFrontPhotoList(kioskEventId);
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
        final fileName = photo.getFileName();
        final filePath = await imageStorage.saveImage(DirectoryPaths.frontImages, photo.embedUrl, fileName);

        frontPhotoPaths.add(filePath);
      } catch (e) {
        logger.e('이미지 저장 중 오류가 발생했습니다: $e');
      }
    }
    return frontPhotoPaths;
  }

  Future<Seletedfrontphoto> getRandomPhoto() async {
    if (state.isEmpty) {
      throw Exception('No front images available');
    }

    try {
      // 파일명에서 정보 추출
      final result = RandomPhotoUtil.getRandomPhotoByWeight(state);

      if (result != null) {
        return result;
      }

      throw Exception('Invalid file name format: ${result?.path}');
    } catch (e) {
      logger.e('이미지 정보 추출 중 오류가 발생했습니다: $e');
      throw Exception('Failed to get random photo');
    }
  }
}
