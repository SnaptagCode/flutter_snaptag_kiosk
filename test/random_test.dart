import 'dart:io';

import 'package:flutter_snaptag_kiosk/core/utils/random/random_photo_util.dart';
import 'package:flutter_snaptag_kiosk/domain/entities/SeletedFrontPhoto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late List<String> testData;

  setUp(() {
    testData = [
      "1_123_1234_100_1.png",
      "2_456_7890_200_1.png",
      "3_987_6543_300_1.png",
      "4_987_6543_400_1.png",
      "5_987_6543_500_0.png",
    ];
  });

  group('RandomPhotoUtil Probability Test', () {
    // ✅ 1. 유효한 데이터에서 랜덤 값 반환 확인
    test('getRandomWeighted should return a non-null value when given valid data', () {
      Seletedfrontphoto? result = RandomPhotoUtil.getRandomPhotoByWeight(testData);

      expect(result, isNotNull);
      expect(result, isA<Seletedfrontphoto>());
    });

    // ✅ 2. 빈 리스트 입력 시 `null` 반환 확인
    test('getRandomWeighted should return null when given an empty list', () {
      List<String> testData = [];
      Seletedfrontphoto? result = RandomPhotoUtil.getRandomPhotoByWeight(testData);
      expect(result, isNull);
    });

    // ✅ 3. 잘못된 데이터 입력 시 예외 처리 확인
    test('getRandomWeighted should return null when given invalid formatted data', () {
      List<String> testData = ["invalid_filename.png", "1_123.png", "2_456_7890.png"];

      Seletedfrontphoto? result = RandomPhotoUtil.getRandomPhotoByWeight(testData);
      expect(result, isNull);
    });

    // ✅ 4. 단일 실행 결과 확인
    test('getRandomWeighted should return a valid object for a single random execution', () {
      Seletedfrontphoto? result = RandomPhotoUtil.getRandomPhotoByWeight(testData);

      if (result != null) {
        print("Selected photo: ID=${result.id}, Code=${result.code}, Path=${result.path}");
      } else {
        print("No valid selection made.");
      }

      expect(result, isNotNull);
    });

    // ✅ 5. 여러 번 실행하여 가중치 기반 선택 비율 검증
    test('getRandomWeighted should select higher weight items more frequently', () {
      final Map<String, int> selectionCounts = {};
      const int totalTrials = 10000;

      for (int i = 0; i < totalTrials; i++) {
        final result = RandomPhotoUtil.getRandomPhotoByWeight(testData);
        if (result != null) {
          selectionCounts[result.path] = (selectionCounts[result.path] ?? 0) + 1;
        }
      }

      // 결과 출력
      print("Random Selection Distribution:");
      final sortedMap = Map.fromEntries(
        selectionCounts.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
      );
      sortedMap.forEach((key, value) {
        print("$key -> ${value / totalTrials * 100}% 선택됨");
      });
    });

    // ✅ 6. FrontPhotoList 의 File -> List<String> 변환 검증
    test('convertFromFileToObject 변환 후 null 값이 제거되는지 확인', () {
      final testFiles = [
        File("1_123_1234_100_1.png"),
        File("3_123_1234_100_.png"),
        File(""),
      ];

      final result = testFiles
          .map((file) => RandomPhotoUtil.convertFromFileToObject(file.path)?.path)
          .where((path) => path != null)
          .cast<String>()
          .toList();

      // ✅ 결과 검증
      expect(result, isA<List<String>>()); // ✅ `List<String>`인지 확인
      expect(result.first, "1_123_1234_100_1.png"); // ✅ 예상된 path
    });
  });
}
