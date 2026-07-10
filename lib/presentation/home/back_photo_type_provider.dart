import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 뒷면 이미지 타입
enum BackPhotoType {
  /// 고정 뒷면 이미지 (추천 이미지)
  fixed,

  /// 커스텀 뒷면 이미지 (사용자 업로드)
  custom,
}

/// 뒷면 출력 스타일 (JKLI-214)
enum BackPhotoLayoutType {
  /// 상/하단 이벤트명·날짜 라벨 포함 — 기존 출력과 동일
  labeled,

  /// 라벨 없이 이미지가 카드 전체를 채움 (임베딩은 유지)
  full,
}

extension BackPhotoLayoutTypeX on BackPhotoLayoutType {
  /// POST /v1/print backPhotoLayoutType 전송 값
  String get serverValue => this == BackPhotoLayoutType.full ? 'FULL' : 'LABELED';
}

/// 뒷면 이미지 선택 상태
class BackPhotoSelection {
  final BackPhotoType type;
  final int? fixedIndex; // 고정 이미지인 경우 선택된 인덱스 (0 또는 1)

  /// 선택된 출력 스타일. null = 미선택(스타일 UI 미노출 포함) —
  /// print 요청에 전송하지 않으며 서버 기본(LABELED)과 동일하게 출력된다.
  final BackPhotoLayoutType? layoutType;

  const BackPhotoSelection({
    required this.type,
    this.fixedIndex,
    this.layoutType,
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

  /// 고정 뒷면 이미지 선택 (인덱스 지정) — 재선택 시 layoutType도 초기화된다
  void selectFixed(int index) {
    state = BackPhotoSelection.fixed(index);
  }

  /// 커스텀 뒷면 이미지 선택
  void selectCustom() {
    state = BackPhotoSelection.custom();
  }

  /// 출력 스타일 선택 (고정 뒷면 전용)
  void selectLayout(BackPhotoLayoutType layout) {
    final current = state;
    if (current == null) return;
    state = BackPhotoSelection(
      type: current.type,
      fixedIndex: current.fixedIndex,
      layoutType: layout,
    );
  }

  /// 선택 초기화
  void reset() => state = null;
}

final backPhotoTypeProvider = StateNotifierProvider<BackPhotoTypeNotifier, BackPhotoSelection?>(
  (ref) => BackPhotoTypeNotifier(),
);
