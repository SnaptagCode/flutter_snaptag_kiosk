import 'dart:math';

import 'package:flutter_snaptag_kiosk/lib.dart';

class RandomPhotoUtil {
  static NominatedPhoto? getRandomPhotoByWeight(List<NominatedPhoto> dataList) {
    try {
      if (dataList.isEmpty) {
        return null;
      }
      // 가중치 추출 및 null 제거
      final List<NominatedPhoto> parsedData = dataList.where((item) => item.embedImage != null).toList(); // 유효한 값만 필터링

      // 총 가중치 계산
      final totalWeight = parsedData.fold(0, (sum, item) => sum + item.selectionWeight);

      // 랜덤 값 생성
      final randomValue = Random().nextInt(totalWeight);

      // 누적 가중치 계산 및 랜덤 값 비교
      int cumulativeWeight = 0;
      return parsedData.firstWhere((item) {
        cumulativeWeight += item.selectionWeight;
        return randomValue < cumulativeWeight;
      });
    } catch (e) {
      logger.e('이미지 정보 추출 중 오류가 발생했습니다: $e');
      return null;
    }
  }
}
