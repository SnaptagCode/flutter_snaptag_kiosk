import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 뒷면 이미지 타입
enum BackPhotoType {
  /// 고정 뒷면 이미지 (추천 이미지)
  fixed,

  /// 커스텀 뒷면 이미지 (사용자 업로드)
  custom,
}

/// 뒷면 이미지 선택 상태
class BackPhotoSelection {
  final BackPhotoType type;
  final int? fixedIndex; // 고정 이미지인 경우 선택된 인덱스 (0 또는 1)

  const BackPhotoSelection({
    required this.type,
    this.fixedIndex,
  });

  /// 고정 뒷면 이미지 선택
  factory BackPhotoSelection.fixed(int index) {
    return BackPhotoSelection(
      type: BackPhotoType.fixed,
      fixedIndex: index,
    );
  }

  /// 커스텀 뒷면 이미지 선택
  factory BackPhotoSelection.custom() {
    return BackPhotoSelection(
      type: BackPhotoType.custom,
      fixedIndex: null,
    );
  }
}

class BackPhotoTypeNotifier extends StateNotifier<BackPhotoSelection?> {
  BackPhotoTypeNotifier() : super(null);

  /// 고정 뒷면 이미지 선택 (인덱스 지정)
  void selectFixed(int index) {
    state = BackPhotoSelection.fixed(index);
  }

  /// 커스텀 뒷면 이미지 선택
  void selectCustom() {
    state = BackPhotoSelection.custom();
  }

  /// 선택 초기화
  void reset() => state = null;
}

final backPhotoTypeProvider = StateNotifierProvider<BackPhotoTypeNotifier, BackPhotoSelection?>(
  (ref) => BackPhotoTypeNotifier(),
);
