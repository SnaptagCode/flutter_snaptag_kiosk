import 'dart:ffi';
import 'dart:io';
import 'dart:math';

import 'package:flutter/rendering.dart';
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
        return extension.endsWith('.jpg') ||
            extension.endsWith('.jpeg') ||
            extension.endsWith('.png');
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
      FileLogger.warning('이미지 목록을 불러오는 중 오류가 발생했습니다: $e');
      return [];
    }
  }

  Future<void> fetch() async {
    try {
      await ref
          .read(imageStorageProvider)
          .clearDirectory(DirectoryPaths.frontImages);

      final kioskEventId =
          ref.read(storageServiceProvider).settings.kioskEventId;

      if (kioskEventId == 0) {
        throw Exception('No kiosk event id available');
      }
      // API를 통해 이미지 목록 가져오기
      final kioskRepo = ref.read(kioskRepositoryProvider);
      final NominatedPhotoList response =
          await kioskRepo.getFrontPhotoList(kioskEventId);
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
        final fileName =
            '${photo.id}_${photo.code}_${photo.embeddingProductId}_${photo.selectionWeight}_${photo.isWin ? 1 : 0}';
        final filePath = await imageStorage.saveImage(
            DirectoryPaths.frontImages, photo.embedUrl, fileName);

        frontPhotoPaths.add(filePath);
      } catch (e) {
        FileLogger.warning('이미지 저장 중 오류가 발생했습니다: $e');
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
      final result = getRandomWeighted(state);

      if (result != null) {
        return result;
      }

      throw Exception('Invalid file name format: ${result?.path}');
    } catch (e) {
      FileLogger.warning('이미지 정보 추출 중 오류가 발생했습니다: $e');
      throw Exception('Failed to get random photo');
    }
  }

  Seletedfrontphoto? getRandomWeighted(List<String> dataList) {
    // 가중치 추출
    final parsedData = dataList
        .map((filePath) {
          final fileName = path.basenameWithoutExtension(filePath);
          final parts = fileName.split('_');
          final id = int.tryParse(parts[0]);
          final code = int.tryParse(parts[1]);
          final embeddingProductId = int.tryParse(parts[2]);
          final weight = int.tryParse(parts[3]) ?? 0;
          final isWin = parts[4] == '1';

          if (id == null || code == null || embeddingProductId == null) {
            return null;
          }
          return Seletedfrontphoto(
            id: id,
            code: code,
            embeddingProductId: embeddingProductId,
            weight: weight,
            isWin: isWin,
            path: filePath,
          );
        })
        .where((item) => item != null)
        .toList(); // 유효한 값만 필터링

    print("paredData: ${parsedData.toString()}");

    // 총 가중치 계산
    final totalWeight = parsedData.fold(0, (sum, item) => sum + item!.weight);

    // 랜덤 값 생성
    final randomValue = Random().nextInt(totalWeight);

    // 누적 가중치 계산 및 랜덤 값 비교
    int cumulativeWeight = 0;
    return parsedData.firstWhere((item) {
      cumulativeWeight += item!.weight;
      return randomValue < cumulativeWeight;
    }, orElse: () => null);
  }

  // 특정 이미지의 정보를 추출하는 메서드
  ({int id, int code, int embeddingProductId})? _getPhotoInfo(
      String imagePath) {
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
      FileLogger.warning('이미지 정보 추출 중 오류가 발생했습니다: $e');
      return null;
    }
  }
}
